/**************************************************
*                                                 *
*        Author: Serguei Nastassi                 *
*        Date:   08.12.2023                       *
*        email:  itoracle@icloud.com              *
*                                                 *
* Backup inventory obj_status to backup table     *
* Diable trigger                                  *
**************************************************/
declare 
 TNAME  PKG_STD.tSTRING;
BEGIN

SELECT  TRIGGER_NAME INTO TNAME
 FROM USER_TRIGGERS T 
  WHERE T.TRIGGER_NAME = 'T_INVENTORY_BUPDATE'
    AND STATUS = 'ENABLED';
  BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE INVENTORY_BACKUP';
   EXCEPTION
   WHEN OTHERS
   THEN
     NULL;
  END;
  EXECUTE IMMEDIATE 'CREATE TABLE INVENTORY_BACKUP AS SELECT * FROM INVENTORY';
  EXECUTE IMMEDIATE 'ALTER TRIGGER T_INVENTORY_BUPDATE DISABLE';
UPDATE INVENTORY
  SET 
    OBJ_STATUS = 0;
COMMIT;
P_EXCEPTION(0, 'Инвентарная картотека переведена в состояние редактирования. Как можно скорее верните в исходное состояние. Вход в систему для других пользователей невозможен. Не совершайте других действий с карточками помимо редактирования');
 EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
P_EXCEPTION(0, 'Инвентарная картотека уже была в состоянии редактирования');
END;