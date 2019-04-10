hisSET SQLBLANKLINES ON
SET COLSEP '|'
set time on
col startup_time    for a20
col instance_name   for a15
col host_name       for a10
col sysdate         for a30
COL "NOME_SERVIDOR" FOR A27
col "BANCO_INICIADO" for a30
col "DATA_E_HORA_SDCA" for a30
SET lines 900 pages 500 trims on
SELECT distinct instance_name Nome_Banco, i.host_name Nome_Servidor, to_char(startup_time,'dd/mm/yyyy hh24:mi:ss') Banco_iniciado,
	d.log_mode, i.status, i.logins, d.open_mode, to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') DATA_E_HORA_SDCA
FROM gv$instance i, gv$database d
/
prompt
prompt
prompt
prompt
prompt

PROMPT ********* SESSÕES ATIVAS DO BANCO DE DADOS *********
prompt
   
set lines 200
set pages 50000
col username format a30
col status format a8
col logon for a20
col SECONDS_IN_WAIT format 9999
Select 
s.inst_id,f.username, f.STATUS,count(f.serial#) as quantidade
  from gv$session f,
       gv$sqlarea s
   where f.inst_id = s.inst_id(+) and f.sql_hash_value = s.hash_value(+)  
   and username is not null and username <> 'SYS'
  group by s.inst_id,f.username, f.STATUS
   order by count(f.sid)
 /
prompt
prompt
prompt
prompt
prompt

--PROMPT ********* ÁREA DE ARCHIVELOG *********
--PROMPT
--prompt
--col DEST_NAME for a20
--col DESTINATION for a50
--select '!df -h '||DESTINATION cmd from V$ARCHIVE_DEST where DESTINATION is not null
--/
PROMPT ********* CONSUMO DE TABLESPACES ACIMA DE 84% *********
	select  distinct
	a.name,
	trunc(b.bytes / (1024 * 1024),2) as "Total Mb",
	trunc(sum(c.bytes) / (1024 * 1024),2) as "Livre Mb",
	trunc((b.bytes / (1024 * 1024)) - (sum(c.bytes) / (1024 * 1024)),2) as "Usado Mb",
	trunc(((b.bytes / (1024 * 1024)) - (sum(c.bytes) / (1024 * 1024))) * 100 / (b.bytes / (1024 * 1024)),2) as "% Usado"
	from    v$tablespace a, dba_free_space c, (select    ts#,
						 sum(bytes) as bytes
			   from      v$datafile
			   group by  ts#
			   ) b
	where   a.ts# = b.ts#
	and     c.tablespace_name = a.name   
	group by a.name, b.bytes
			HAVING trunc(((b.bytes / (1024 * 1024)) - (sum(c.bytes) / (1024 * 1024))) * 100 / (b.bytes / (1024 * 1024)),2) > 84
		order by "% Usado" desc;
prompt
prompt
prompt
prompt
prompt

PROMPT ********* CONSUMO DE DISKGROUPS *********

SET LINE 200
TTITLE LEFT SKIP 1 "ASM DISK GROUPS" SKIP 2
	SET LINES 200 PAGES 999
	CLEAR COLUMNS
	COLUMN "GROUP"      FORMAT 999  
	COLUMN "GROUP_NAME" FORMAT a30
	COLUMN "STATE"      FORMAT a10
	COLUMN "TYPE"       FORMAT a7
	COLUMN "TOTAL_MB"   FORMAT 999,999,000
	COLUMN "FREE_MB"    FORMAT 99,999,000
	SELECT 	group_number  "GROUP",
			name          "GROUP_NAME",
			state         "STATE",
			type          "TYPE",
			total_mb      "TOTAL_MB",
			free_mb       "FREE_MB" ,
			DECODE(100 - ceil(FREE_MB/TOTAL_MB*100), NULL, 100, 100 - ceil(FREE_MB/TOTAL_MB*100)) "% USADO"
	FROM    v$asm_diskgroup, v$instance where state = 'CONNECTED';
TTITLE OFF

prompt
prompt
prompt
prompt
prompt

PROMPT ********* ÁREA DE DB_RECOVER *********
select * from  v$flash_recovery_area_usage
/

prompt
prompt
prompt
prompt
prompt

PROMPT ********* INSTANCIA ATIVAS *********
prompt
!ps -ef | grep pmon
prompt
prompt
prompt
prompt
prompt

prompt ********* TEMPO DE UPTIME DO SERVIDOR *********
prompt
!uptime
prompt
prompt
prompt
prompt
prompt

prompt ********* LISTENER *********
prompt
!lsnrctl status 
prompt
prompt
prompt
prompt
prompt

prompt ********* EXECUTAR A LINHA ABAIXO PARA VERIFICAR ALERT *********
prompt
col "cmd sqlplus" for a80
select '!tail '||value||'/alert_'||d.instance_name||'.log' "cmd sqlplus" from v$parameter p ,v$instance d where p.name = 'background_dump_dest'
/