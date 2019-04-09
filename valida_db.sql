spool ./evidencia.log --write in file evidencia.log
--Verify dabatase status
select instance_name, status from v$instance;
spool off;
exit;