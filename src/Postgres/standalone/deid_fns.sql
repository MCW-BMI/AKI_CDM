SET ROLE fh_phi_admin;

CREATE OR REPLACE FUNCTION gpc_aki_project.aki_offset_from_zid(text)
 RETURNS interval
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
DECLARE v_num_value integer;
DECLARE v_mod_value integer;
DECLARE v_interval interval;
BEGIN
      v_num_value := ('x' || substring(encode(digest('<secret>' || $1, 'sha256'),'hex') FROM 1 FOR 8))::bit(32)::bigint % 20;
      v_mod_value := CASE WHEN v_num_value < 10
                          THEN v_num_value + 1
                          ELSE v_num_value - 20
                     END;
      v_interval := (v_mod_value::text || ' days')::interval;
RETURN v_interval;
END;
$function$
;
CREATE OR REPLACE FUNCTION gpc_aki_project.aki_phi_id(text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
    SELECT substring(encode(digest('<secret>' || $1, 'sha256'), 'hex') FROM 1 FOR 16)
$function$
a
