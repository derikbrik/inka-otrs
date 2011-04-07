SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS `mydb` ;
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `mydb`;

-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_template`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_template` (
  `id` INT NOT NULL ,
  `name` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_category`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_category` (
  `id` INT NOT NULL ,
  `id_parent` INT NOT NULL ,
  `id_template` INT NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `inka_id_parent_FK` (`id_parent` ASC) ,
  INDEX `inka_id_template_category_FK` (`id_template` ASC) ,
  CONSTRAINT `inka_id_parent_FK`
    FOREIGN KEY (`id_parent` )
    REFERENCES `mydb`.`inka_category` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_template_category_FK`
    FOREIGN KEY (`id_template` )
    REFERENCES `mydb`.`inka_ci_template` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_state`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_state` (
  `id` INT NOT NULL ,
  `id_category` INT NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `inka_id_category_FK` (`id_category` ASC) ,
  CONSTRAINT `inka_id_category_FK`
    FOREIGN KEY (`id_category` )
    REFERENCES `mydb`.`inka_category` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_provider_list`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_provider_list` (
  `id` INT NOT NULL ,
  `id_category` INT NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `inka_id_category_provider_list_FK` (`id_category` ASC) ,
  CONSTRAINT `inka_id_category_provider_list_FK`
    FOREIGN KEY (`id_category` )
    REFERENCES `mydb`.`inka_category` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci` (
  `id` INT NOT NULL ,
  `id_category` INT NOT NULL ,
  `unique_name` VARCHAR(255) NOT NULL ,
  `serial_number` VARCHAR(255) NULL ,
  `description` TEXT NULL ,
  `id_state` INT NOT NULL ,
  `id_provider` INT NOT NULL ,
  `cost` DECIMAL(10,3) NULL ,
  `acquisition_day` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `inka_id_category_FK` (`id_category` ASC) ,
  INDEX `inka_id_state_FK` (`id_state` ASC) ,
  INDEX `inka_id_provider_ci_FK` (`id_provider` ASC) ,
  CONSTRAINT `inka_id_category_FK`
    FOREIGN KEY (`id_category` )
    REFERENCES `mydb`.`inka_category` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_state_FK`
    FOREIGN KEY (`id_state` )
    REFERENCES `mydb`.`inka_ci_state` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_provider_ci_FK`
    FOREIGN KEY (`id_provider` )
    REFERENCES `mydb`.`inka_ci_provider_list` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_metatype`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_metatype` (
  `id` INT NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_generic_list`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_generic_list` (
  `id` INT NOT NULL ,
  `id_list` INT NOT NULL ,
  `id_category` INT NOT NULL ,
  `list_name` VARCHAR(255) NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  `value` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `inka_id_category_generic_list_FK` (`id_category` ASC) ,
  CONSTRAINT `inka_id_category_generic_list_FK`
    FOREIGN KEY (`id_category` )
    REFERENCES `mydb`.`inka_category` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_file`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_file` (
  `id` INT NOT NULL ,
  `filename` VARCHAR(255) NOT NULL ,
  `content_type` VARCHAR(255) NULL ,
  `content_size` VARCHAR(30) NULL ,
  `content` LONGBLOB NOT NULL ,
  `creation_date` DATETIME NOT NULL ,
  `modification_date` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_properties_group`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_properties_group` (
  `id` INT NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_template_properties`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_template_properties` (
  `id` INT NOT NULL ,
  `id_template` INT NOT NULL ,
  `id_metatype` INT NOT NULL ,
  `id_properties_group` INT NOT NULL ,
  `caption` VARCHAR(255) NOT NULL ,
  `mandatory` SMALLINT NULL ,
  `display` SMALLINT NULL ,
  INDEX `inka_id_template_template_properties_FK` (`id_template` ASC) ,
  INDEX `inka_id_metatype_template_properies_FK` (`id_metatype` ASC) ,
  PRIMARY KEY (`id`) ,
  INDEX `inka_id_properties_group_template_properties_properties_group` (`id_properties_group` ASC) ,
  CONSTRAINT `inka_id_template_template_properties_FK`
    FOREIGN KEY (`id_template` )
    REFERENCES `mydb`.`inka_ci_template` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_metatype_template_properies_FK`
    FOREIGN KEY (`id_metatype` )
    REFERENCES `mydb`.`inka_metatype` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_properties_group_template_properties_properties_group`
    FOREIGN KEY (`id_properties_group` )
    REFERENCES `mydb`.`inka_ci_properties_group` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_properties`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_properties` (
  `id` INT NOT NULL ,
  `id_ci` INT NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  `id_metatype` INT NOT NULL ,
  `value_int` INT NULL ,
  `value_float` DECIMAL(10,5) NULL ,
  `value_str` VARCHAR(255) NULL ,
  `value_date_time` DATETIME NULL ,
  `id_generic_item_list` INT NULL ,
  `id_file` INT NULL ,
  `id_template_properties` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `inka_id_ci_FK` (`id_ci` ASC) ,
  INDEX `inka_id_metatype_FK` (`id_metatype` ASC) ,
  INDEX `inka_id_generic_item_list_properties_FK` (`id_generic_item_list` ASC) ,
  INDEX `inka_id_file_FK` (`id_file` ASC) ,
  INDEX `inka_id_template_properties_template_properties_properties` (`id_template_properties` ASC) ,
  CONSTRAINT `inka_id_ci_FK`
    FOREIGN KEY (`id_ci` )
    REFERENCES `mydb`.`inka_ci` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_metatype_FK`
    FOREIGN KEY (`id_metatype` )
    REFERENCES `mydb`.`inka_metatype` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_generic_item_list_properties_FK`
    FOREIGN KEY (`id_generic_item_list` )
    REFERENCES `mydb`.`inka_ci_generic_list` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_file_FK`
    FOREIGN KEY (`id_file` )
    REFERENCES `mydb`.`inka_file` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_id_template_properties_template_properties_properties`
    FOREIGN KEY (`id_template_properties` )
    REFERENCES `mydb`.`inka_ci_template_properties` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_history`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_history` (
  `id` INT NOT NULL ,
  `modification_date` DATETIME NOT NULL ,
  `modificated_by` INT NOT NULL ,
  `id_ci` INT NOT NULL ,
  `new_state` INT NOT NULL ,
  `note` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `inka_id_ci_history_FK` (`id_ci` ASC) ,
  INDEX `inka_new_state_FK` (`new_state` ASC) ,
  CONSTRAINT `inka_id_ci_history_FK`
    FOREIGN KEY (`id_ci` )
    REFERENCES `mydb`.`inka_ci` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inka_new_state_FK`
    FOREIGN KEY (`new_state` )
    REFERENCES `mydb`.`inka_ci_state` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_link_type`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_link_type` (
  `id` INT NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_user_link_type`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_user_link_type` (
  `idtable1` INT NOT NULL ,
  `name` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`idtable1`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_ci_link`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_ci_link` (
  `id_ci_up` INT NOT NULL ,
  `id_ci_down` INT NOT NULL ,
  `id_link_type` INT NOT NULL ,
  PRIMARY KEY (`id_ci_up`, `id_link_type`, `id_ci_down`) ,
  INDEX `fk_inka_ci_ci_link_inka_ci1` (`id_ci_up` ASC) ,
  INDEX `fk_inka_ci_ci_link_inka_ci2` (`id_ci_down` ASC) ,
  INDEX `fk_inka_ci_ci_link_inka_ci_link_type1` (`id_link_type` ASC) ,
  CONSTRAINT `fk_inka_ci_ci_link_inka_ci1`
    FOREIGN KEY (`id_ci_up` )
    REFERENCES `mydb`.`inka_ci` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_inka_ci_ci_link_inka_ci2`
    FOREIGN KEY (`id_ci_down` )
    REFERENCES `mydb`.`inka_ci` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_inka_ci_ci_link_inka_ci_link_type1`
    FOREIGN KEY (`id_link_type` )
    REFERENCES `mydb`.`inka_ci_link_type` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`inka_ci_user_link`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `mydb`.`inka_ci_user_link` (
  `inka_ci_user_link_type_idtable1` INT NOT NULL ,
  `inka_ci_id` INT NOT NULL ,
  `id_user` INT NOT NULL ,
  INDEX `fk_inka_ci_user_link_inka_ci_user_link_type1` (`inka_ci_user_link_type_idtable1` ASC) ,
  INDEX `fk_inka_ci_user_link_inka_ci1` (`inka_ci_id` ASC) ,
  PRIMARY KEY (`id_user`, `inka_ci_id`, `inka_ci_user_link_type_idtable1`) ,
  CONSTRAINT `fk_inka_ci_user_link_inka_ci_user_link_type1`
    FOREIGN KEY (`inka_ci_user_link_type_idtable1` )
    REFERENCES `mydb`.`inka_ci_user_link_type` (`idtable1` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_inka_ci_user_link_inka_ci1`
    FOREIGN KEY (`inka_ci_id` )
    REFERENCES `mydb`.`inka_ci` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
