SET ROLE fh_phi_admin; 
\COPY  gpc_aki_project.mcw_aki_demo  TO '/tmp/mcw_aki_demo.dsv'  WITH (FORMAT 'csv', HEADER true, DELIMITER '|');
\COPY  gpc_aki_project.mcw_aki_vital TO '/tmp/mcw_aki_vital.dsv' WITH (FORMAT 'csv', HEADER true, DELIMITER '|');
\COPY  gpc_aki_project.mcw_aki_dx    TO '/tmp/mcw_aki_dx.dsv'    WITH (FORMAT 'csv', HEADER true, DELIMITER '|');
\COPY  gpc_aki_project.mcw_aki_px    TO '/tmp/mcw_aki_px.dsv'    WITH (FORMAT 'csv', HEADER true, DELIMITER '|');
\COPY  gpc_aki_project.mcw_aki_lab   TO '/tmp/mcw_aki_lab.dsv'   WITH (FORMAT 'csv', HEADER true, DELIMITER '|');
\COPY  gpc_aki_project.mcw_aki_pmed  TO '/tmp/mcw_aki_pmed.dsv'  WITH (FORMAT 'csv', HEADER true, DELIMITER '|');
\COPY  gpc_aki_project.mcw_aki_amed  TO '/tmp/mcw_aki_amed.dsv'  WITH (FORMAT 'csv', HEADER true, DELIMITER '|');
\COPY  gpc_aki_project.mcw_aki_dmed  TO '/tmp/mcw_aki_dmed.dsv'  WITH (FORMAT 'csv', HEADER true, DELIMITER '|');
