SET ROLE fh_phi_admin;

DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_onsets;
CREATE TABLE gpc_aki_project.mcw_aki_onsets AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,admit_date         + gpc_aki_project.aki_offset_from_zid(patid) AS admit_date
 ,discharge_date     + gpc_aki_project.aki_offset_from_zid(patid) AS discharge_date
 ,serum_creat_base
 ,nonaki_anchor      + gpc_aki_project.aki_offset_from_zid(patid) AS nonaki_anchor
 ,nonaki_since_admit 
 ,non_aki_scr        
 ,non_aki_inc        
 ,aki1_onset         + gpc_aki_project.aki_offset_from_zid(patid) AS aki1_onset
 ,aki1_since_admit   
 ,aki1_scr           
 ,aki1_inc           
 ,aki2_onset         + gpc_aki_project.aki_offset_from_zid(patid) AS aki2_onset
 ,aki2_since_admit 
 ,aki2_scr          
 ,aki2_inc          
 ,aki3_onset         + gpc_aki_project.aki_offset_from_zid(patid) AS  aki3_onset
 ,aki3_since_admit
 ,aki3_scr        
 ,aki3_inc        
 FROM gpc_aki_project.aki_onsets
);


DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_demo;
CREATE TABLE gpc_aki_project.mcw_aki_demo AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,birth_date + gpc_aki_project.aki_offset_from_zid(patid) AS birth_date
 ,age               
 ,sex               
 ,race              
 ,hispanic          
 ,death_date + gpc_aki_project.aki_offset_from_zid(patid) AS death_date
 ,ddays_since_enc   
 ,death_date_impute 
 ,death_source      
FROM gpc_aki_project.aki_demo
);

DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_vital;
CREATE TABLE gpc_aki_project.mcw_aki_vital AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,measure_date_time + gpc_aki_project.aki_offset_from_zid(patid) AS measure_date_time
 ,ht                
 ,wt                
 ,systolic          
 ,diastolic         
 ,original_bmi      
 ,smoking           
 ,tobacco           
 ,tobacco_type      
 ,days_since_admit  
FROM gpc_aki_project.aki_vital
);

DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_dx;
CREATE TABLE gpc_aki_project.mcw_aki_dx AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,dx               
 ,dx_type          
 ,dx_source        
 ,pdx              
 ,dx_date + gpc_aki_project.aki_offset_from_zid(patid) AS dx_date
 ,days_since_admit 
FROM gpc_aki_project.aki_dx
);

DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_px;
CREATE TABLE gpc_aki_project.mcw_aki_px AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,px              
 ,px_type         
 ,px_source       
 ,px_date          + gpc_aki_project.aki_offset_from_zid(patid) AS px_date
 ,days_since_admit
FROM gpc_aki_project.aki_px
);

DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_pmed;
CREATE TABLE gpc_aki_project.mcw_aki_pmed AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,rx_order_date_time + gpc_aki_project.aki_offset_from_zid(patid) AS  rx_order_date_time
 ,rx_start_date      + gpc_aki_project.aki_offset_from_zid(patid) AS  rx_start_date
 ,rx_end_date        + gpc_aki_project.aki_offset_from_zid(patid) AS  rx_end_date
 ,rx_basis           
 ,rxnorm_cui         
 ,rx_quantity        
 ,rx_refills         
 ,rx_days_supply     
 ,rx_frequency       
 ,rx_quantity_daily  
 ,days_since_admit   
FROM gpc_aki_project.aki_pmed
);


DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_amed;
CREATE TABLE gpc_aki_project.mcw_aki_amed AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,medadmin_start_date_time + gpc_aki_project.aki_offset_from_zid(patid) AS medadmin_start_date_time
 ,medadmin_stop_date_time  + gpc_aki_project.aki_offset_from_zid(patid) AS medadmin_stop_date_time
 ,medadmin_type            
 ,medadmin_code            
 ,medadmin_dose_admin      
 ,medadmin_route           
 ,medadmin_source          
 ,days_since_admit         
FROM gpc_aki_project.aki_amed
);

DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_dmed;
CREATE TABLE gpc_aki_project.mcw_aki_dmed AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,prescribingid
 ,dispense_date           + gpc_aki_project.aki_offset_from_zid(patid) AS dispense_date
 ,ndc                     
 ,dispense_source         
 ,dispense_sup            
 ,dispense_amt            
 ,dispense_dose_disp      
 ,dispense_dose_disp_unit 
 ,dispense_route          
 ,days_since_admit        
FROM gpc_aki_project.aki_dmed
);


DROP TABLE IF EXISTS gpc_aki_project.mcw_aki_lab;
CREATE TABLE gpc_aki_project.mcw_aki_lab AS (
SELECT
  gpc_aki_project.aki_phi_id(patid) AS patid
 ,gpc_aki_project.aki_phi_id(encounterid) AS encounterid
 ,lab_order_date     + gpc_aki_project.aki_offset_from_zid(patid) AS lab_order_date
 ,specimen_date_time + gpc_aki_project.aki_offset_from_zid(patid) AS specimen_date_time
 ,result_date_time   + gpc_aki_project.aki_offset_from_zid(patid) AS result_date_time
 ,specimen_source   
 ,lab_loinc         
 ,lab_px            
 ,lab_px_type       
 ,result_qual       
 ,result_num        
 ,result_unit       
 ,days_since_admit  
FROM gpc_aki_project.aki_lab
);


