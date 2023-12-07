/**************************************************
*                                                 *
*        Author: Serguei Nastassi                 *
*        Date:   08.12.2023                       *
*        email:  itoracle@icloud.com              *
*                                                 *
* Restore inventory obj_status from backup        *
* Enable trigger                                  *
**************************************************/
declare 
 TNAME  PKG_STD.tSTRING;
BEGIN

SELECT  TRIGGER_NAME INTO TNAME
 FROM USER_TRIGGERS T 
  WHERE T.TRIGGER_NAME = 'T_INVENTORY_BUPDATE'
    AND STATUS = 'ENABLED';
P_EXCEPTION(0, 'Картотека не требует восстановления после редактирования');
 EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
UPDATE INVENTORY T
  SET T.OBJ_STATUS = 
    (SELECT B.OBJ_STATUS
      FROM INVENTORY_BACKUP B
        WHERE B.RN = T.RN);
EXECUTE IMMEDIATE 'ALTER TRIGGER T_INVENTORY_BUPDATE ENABLE';
P_EXCEPTION(0, 'Картотека восстановлена после редактирования в рабочее состояние');
END;