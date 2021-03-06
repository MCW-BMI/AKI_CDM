#### test: med collections ####
source("./R/util.R")
require_libraries(c("DBI",
                    "tidyr",
                    "dplyr",
                    "magrittr",
                    "stringr"))

params<-list(  DBMS_type="Oracle",
               driver_type="OCI",
               remote_CDM=FALSE,
               incl_NDC=FALSE)

config_file<-read.csv("./config/config.csv",stringsAsFactors = F)
conn<-connect_to_db(DBMS_type=params$DBMS_type,
                    driver_type=params$driver_type,
                    config_file=config_file)
DBMS_type<-attr(conn,"DBMS_type")


#set up parameters
remote_CDM=params$remote_CDM
cdm_db_link=config_file$cdm_db_link
cdm_db_name=config_file$cdm_db_name
cdm_db_schema=config_file$cdm_db_schema
start_date="2010-01-01"
end_date="2019-12-31"
verb=F

# auxilliary summaries and tables
Table1<-readRDS("./data/Table1.rda")
enc_tot<-length(unique(Table1$ENCOUNTERID))

#statements to be tested
sql<-parse_sql(paste0("./src/",params$DBMS_type,"/collect_med.sql"),
               cdm_db_link=config_file$cdm_db_link,
               cdm_db_name=config_file$cdm_db_name,
               cdm_db_schema=config_file$cdm_db_schema)

med<-execute_single_sql(conn,
                        statement=sql$statement,
                        write=(sql$action=="write")) 



med %<>%
  dplyr::mutate(RX_EXPOS=round(pmax(as.numeric(difftime(MEDADMIN_START_DATE_TIME,MEDADMIN_STOP_DATE_TIME,units="days")),1))) %>%
  dplyr::rename(sdsa=DAYS_SINCE_ADMIT) %>%
  dplyr::select(PATID,ENCOUNTERID,MEDADMIN_CODE,MEDADMIN_TYPE,RX_EXPOS,sdsa) %>%
  mutate(RX_QUANTITY_DAILY=1) %>%
  unite("key",c("MEDADMIN_CODE","MEDADMIN_TYPE","MEDADMIN_ROUTE"),sep=":")

med<-readRDS("./data/AKI_MED.rda")

#re-calculate medication exposure
chunk_num<-20
enc_chunk<-med %>% dplyr::select(ENCOUNTERID) %>% unique %>%
  mutate(chunk_id=sample(1:chunk_num,n(),replace=T))

med2<-c()
for(i in 1:chunk_num){
  start_i<-Sys.time()
  
  #--subset ith chunk
  med_sub<-med %>% 
    semi_join(enc_chunk %>% filter(chunk_id==i),by="ENCOUNTERID")
  
  #--collect single-day exposure
  med_sub2<-med_sub %>% filter(RX_EXPOS<=1) %>% 
    dplyr::mutate(dsa=sdsa,value=RX_QUANTITY_DAILY) %>%
    dplyr::select(ENCOUNTERID,key,value,dsa)
  
  #--for multi-day exposed med, converted to daily exposure
  med_expand<-med_sub[rep(row.names(med_sub),(med_sub$RX_EXPOS+1)),] %>%
    group_by(ENCOUNTERID,key,RX_QUANTITY_DAILY,sdsa) %>%
    dplyr::mutate(expos_daily=1:n()-1) %>% 
    dplyr::summarize(dsa=paste0(sdsa+expos_daily,collapse=",")) %>%
    ungroup %>% dplyr::rename(value=RX_QUANTITY_DAILY) %>%
    dplyr::select(ENCOUNTERID,key,value,dsa) %>%
    mutate(dsa=strsplit(dsa,",")) %>%
    unnest(dsa) %>%
    mutate(dsa=as.numeric(dsa))
  
  #--merge overlapped precribing intervals (pick the higher exposure)
  med_sub2 %<>% bind_rows(med_expand) %>%
    group_by(ENCOUNTERID,key,dsa) %>%
    dplyr::summarize(value=max(value)) %>%
    ungroup
  
  #--identify non-overlapped exposure episodes and determines the real sdsa
  med_sub2 %<>%
    group_by(ENCOUNTERID,key) %>%
    dplyr::mutate(dsa_lag=lag(dsa,n=1L)) %>%
    ungroup %>%
    mutate(sdsa=ifelse(is.na(dsa_lag)|dsa > dsa_lag+1,dsa,NA)) %>%
    fill(sdsa,.direction="down") 
  
  med_sub2 %<>%
    group_by(ENCOUNTERID,key,sdsa) %>%
    dplyr::summarize(RX_EXPOS=pmax(1,sum(value,na.rm=T)),
                     value=paste0(value,collapse=","), #expanded daily exposure
                     dsa=paste0(dsa,collapse=",")) %>%  #expanded dsa for daily exposure
    ungroup
  
  med2 %<>% bind_rows(med_sub2)
  
  lapse_i<-Sys.time()-start_i
  cat("finish chunk",i,"in",lapse_i,units(lapse_i),".\n")
}

saveRDS(med2,file="./data/AKI_MED.rda")
#collect summaries
med_summ<-med2 %>% 
  dplyr::select(ENCOUNTERID,key,sdsa,RX_EXPOS) %>%
  mutate(dsa_grp=case_when(sdsa < 0 ~ "0>",
                           sdsa >=0 & sdsa < 1 ~ "1",
                           sdsa >=1 & sdsa < 2 ~ "2",
                           sdsa >=2 & sdsa < 3 ~ "3",
                           sdsa >=3 & sdsa < 4 ~ "4",
                           sdsa >=4 & sdsa < 5 ~ "5",
                           sdsa >=5 & sdsa < 6 ~ "6",
                           sdsa >=6 & sdsa < 7 ~ "7",
                           sdsa >=7 ~ "7<")) %>%
  group_by(key,dsa_grp) %>%
  dplyr::summarize(record_cnt=n(),
                   enc_cnt=length(unique(ENCOUNTERID)),
                   min_expos=min(RX_EXPOS,na.rm=T),
                   mean_expos=round(mean(RX_EXPOS,na.rm=T)),
                   sd_expos=round(sd(RX_EXPOS,na.rm=T)),
                   median_expos=round(median(RX_EXPOS,na.rm=T)),
                   max_expos=max(RX_EXPOS,na.rm=T)) %>%
  ungroup %>%
  #HIPPA, low counts masking
  mutate(enc_cnt=ifelse(as.numeric(enc_cnt)<11,"<11",as.character(enc_cnt)),
         record_cnt=ifelse(as.numeric(record_cnt)<11,"<11",as.character(record_cnt)),
         sd_expos=ifelse(is.na(sd_expos),0,sd_expos)) %>%
  dplyr::mutate(cov_expos=round(sd_expos/mean_expos,1)) %>%
  gather(summ,summ_val,-key,-dsa_grp) %>%
  spread(dsa_grp,summ_val) %>%
  arrange(key,summ)


#data for plotting
Table1<-readRDS("./data/Table1.rda")
enc_tot<-length(unique(Table1$ENCOUNTERID))

med_temp<-med_summ %>% 
  filter(summ %in% c("enc_cnt","median_expos")) %>% 
  gather(dsa_grp,summ_val,-summ,-key) %>%
  filter(!is.na(summ_val) & (summ_val!="<11")) %>%
  mutate(summ_val=as.numeric(summ_val)) %>%
  spread(summ,summ_val) %>%
  filter(!is.na(median_expos) & enc_cnt>=enc_tot*0.001) %>%
  arrange(median_expos) %>%
  group_by(dsa_grp) %>%
  dplyr::mutate(label=ifelse(dense_rank(-enc_cnt)<=3,key,"")) %>%
  ungroup %>%
  dplyr::mutate(label=ifelse(label!="",label,
                             ifelse(dense_rank(-median_expos)<=2,key,"")))


if(nrow(med_temp)>0){
  ggplot(med_temp,aes(x=dsa_grp,y=enc_cnt,color=median_expos,label=label)) +
    geom_point() + geom_text_repel()+
    scale_y_continuous(sec.axis = sec_axis(trans= ~./enc_tot,
                                           name = 'Percentage'))+
    scale_color_gradient2(low = "green",mid="blue",high ="red",
                          midpoint = 2)+
    labs(x="Start Date",y="Encounter Counts",color="Median Exposure (days)",
         title="Figure 4 - Medication Exposure Summaries")
  
  med_report<-med_temp %>%
    mutate(key=gsub(".*_","",gsub("\\:.*","",key))) %>%
    arrange(desc(enc_cnt)) %>%
    dplyr::select(key) %>% 
    unique %>% slice(1:3) %>%
    mutate(rx_name=lapply(key,get_rxcui_nm))
  
  freq_med<-c()
  for(k in 1:nrow(med_report)){
    freq_med<-c(freq_med,paste0(med_report$key[k],"(",med_report$rx_name[k],")")) 
  }
  
  med_report<-med_temp %>%
    mutate(key=gsub(".*_","",gsub("\\:.*","",key))) %>%
    arrange(desc(median_expos)) %>%
    dplyr::select(key) %>%
    unique %>% slice(1:3) %>%
    mutate(rx_name=lapply(key,get_rxcui_nm))
  
  intens_med<-c()
  for(k in 1:nrow(med_report)){
    intens_med<-c(intens_med,paste0(med_report$key[k],"(",med_report$rx_name[k],")")) 
  }
  
  description<-paste0("Figure4 demonstrates average exposures for drug starting at X days since admission. 
                      It helps identify typical medciations dispensed (:01) or administered(:02) during the course of stay. 
                      (e.g. the typical medications identified are",paste(freq_med,collapse=","),
                      "; while drugs such as ",paste(intens_med,collapse=","), 
                      "are used with a relative longer exposure than the others).")
}else{
  description<-"Medication exposure are too low as no medication identifier has a coverage of more than 0.1% of the study population."
}

