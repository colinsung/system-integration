-- ===============LICENSE_START=======================================================
-- Acumos Apache-2.0
-- ===================================================================================
-- Copyright (C) 2017-2020 AT&T Intellectual Property & Tech Mahindra.
-- All rights reserved.
-- ===================================================================================
-- This Acumos software file is distributed by AT&T and Tech Mahindra
-- under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- This file is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ===============LICENSE_END=========================================================

-- DDL and DML for tables managed by the Common Data Service version 3.1.*
-- No database is created or specified to allow flexible deployment;
-- also see script cmn-data-svc-dml-opt-3.1-rev1.sql with images.

-- DDL --

CREATE TABLE C_USER (
  USER_ID CHAR(36) NOT NULL PRIMARY KEY,
  FIRST_NAME VARCHAR(50),
  MIDDLE_NAME VARCHAR(50),
  LAST_NAME VARCHAR(50),
  ORG_NAME VARCHAR(50),
  EMAIL VARCHAR(100) NOT NULL,
  LOGIN_NAME VARCHAR(25) NOT NULL,
  LOGIN_HASH VARCHAR(64),
  LOGIN_PASS_EXPIRE_DATE TIMESTAMP NULL DEFAULT NULL,
  -- JSON web token
  AUTH_TOKEN VARCHAR(4096),
  ACTIVE_YN CHAR(1) NOT NULL DEFAULT 'Y',
  LAST_LOGIN_DATE TIMESTAMP NULL DEFAULT NULL,
  LOGIN_FAIL_COUNT SMALLINT NULL,
  LOGIN_FAIL_DATE TIMESTAMP NULL DEFAULT NULL,
  -- LONGBLOB is overkill but allows schema validation
  PICTURE LONGBLOB,
  API_TOKEN VARCHAR(64),
  VERIFY_TOKEN_HASH VARCHAR(64),
  VERIFY_EXPIRE_DATE TIMESTAMP NULL DEFAULT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  UNIQUE INDEX C_USER_C_EMAIL (EMAIL),
  UNIQUE INDEX C_USER_C_LOGIN_NAME (LOGIN_NAME)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_ROLE (
  ROLE_ID CHAR(36) NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL,
  ACTIVE_YN CHAR(1) DEFAULT 'Y' NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  UNIQUE INDEX C_ROLE_C_NAME (NAME)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Many:many mapping of user to role requires a map (join) table
CREATE TABLE C_USER_ROLE_MAP (
  USER_ID CHAR(36) NOT NULL,
  ROLE_ID CHAR(36) NOT NULL,
  PRIMARY KEY (USER_ID, ROLE_ID),
  CONSTRAINT FK_C_USER_ROLE_MAP_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID),
  CONSTRAINT FK_C_USER_ROLE_MAP_C_ROLE FOREIGN KEY (ROLE_ID) REFERENCES C_ROLE (ROLE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_ROLE_FUNCTION (
  ROLE_FUNCTION_ID CHAR(36) NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL,
  ROLE_ID CHAR(36) NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_ROLE_FUNCTION_C_ROLE FOREIGN KEY (ROLE_ID) REFERENCES C_ROLE (ROLE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_CATALOG (
  CATALOG_ID CHAR(36) NOT NULL PRIMARY KEY,
  ACCESS_TYPE_CD CHAR(2) NOT NULL,
  SELF_PUBLISH_YN CHAR(1) NOT NULL DEFAULT 'N',
  NAME VARCHAR(50) NOT NULL,
  PUBLISHER VARCHAR(64) NOT NULL,
  DESCRIPTION VARCHAR(1024),
  URL VARCHAR(512) NOT NULL,
  ORIGIN VARCHAR(512),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  UNIQUE INDEX C_CATALOG_C_NAME (NAME)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_PEER (
  PEER_ID CHAR(36) NOT NULL PRIMARY KEY,
  NAME VARCHAR(50) NOT NULL,
  -- X.509 certificate subject name
  SUBJECT_NAME VARCHAR(100) NOT NULL,
  DESCRIPTION VARCHAR(512),
  API_URL VARCHAR(512) NOT NULL,
  WEB_URL VARCHAR(512),
  IS_SELF CHAR(1) NOT NULL DEFAULT 'N',
  IS_LOCAL CHAR(1) NOT NULL DEFAULT 'N',
  CONTACT1 VARCHAR(100) NOT NULL,
  STATUS_CD CHAR(2) NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_PEER_C_SUBJECT_NAME UNIQUE (SUBJECT_NAME)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_PEER_SUB (
  SUB_ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  PEER_ID CHAR(36) NOT NULL,
  -- MariaDB does not support JSON column type
  SELECTOR VARCHAR(1024) CHECK (SELECTOR IS NULL OR JSON_VALID(SELECTOR)),
  OPTIONS VARCHAR(1024) CHECK (OPTIONS IS NULL OR JSON_VALID(OPTIONS)),
  -- Seconds
  REFRESH_INTERVAL INT,
  -- Bytes
  MAX_ARTIFACT_SIZE INT,
  USER_ID CHAR(36) NOT NULL,
  PROCESSED_DATE TIMESTAMP NULL DEFAULT 0,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_PEER_SUB_C_PEER FOREIGN KEY (PEER_ID) REFERENCES C_PEER (PEER_ID),
  CONSTRAINT C_PEER_SUB_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_USER_LOGIN_PROVIDER (
  USER_ID CHAR(36) NOT NULL,
  PROVIDER_CD CHAR(2) NOT NULL,
  PROVIDER_USER_ID VARCHAR(255) NOT NULL,
  RANK SMALLINT NOT NULL,
  DISPLAY_NAME VARCHAR(256),
  PROFILE_URL VARCHAR(512),
  IMAGE_URL VARCHAR(512),
  SECRET VARCHAR(256),
  ACCESS_TOKEN  VARCHAR(256) NOT NULL,
  REFRESH_TOKEN VARCHAR(256),
  EXPIRE_TIME TIMESTAMP NOT NULL DEFAULT 0,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_USER_LOGIN_PROVIDER_PK PRIMARY KEY (USER_ID, PROVIDER_CD, PROVIDER_USER_ID),
  CONSTRAINT C_USER_LOGIN_PROVIDER_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_SOLUTION (
  SOLUTION_ID CHAR(36) NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  ACTIVE_YN CHAR(1) DEFAULT 'Y' NOT NULL,
  MODEL_TYPE_CD CHAR(2),
  TOOLKIT_TYPE_CD CHAR(2),
  -- MariaDB does not support JSON column type
  METADATA VARCHAR(1024) CHECK (METADATA IS NULL OR JSON_VALID(METADATA)),
  SOURCE_ID CHAR(36),
  ORIGIN VARCHAR(512),
  -- LONGBLOB is overkill but allows schema validation
  PICTURE LONGBLOB,
  VIEW_COUNT INT,
  DOWNLOAD_COUNT INT,
  LAST_DOWNLOAD TIMESTAMP NULL DEFAULT 0,
  RATING_COUNT INT,
  RATING_AVG_TENTHS INT,
  FEATURED_YN CHAR(1),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_SOLUTION_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID),
  CONSTRAINT C_SOLUTION_C_PEER FOREIGN KEY (SOURCE_ID) REFERENCES C_PEER (PEER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Many:one mapping with solution; no need for map (join) table
CREATE TABLE C_SOLUTION_REV (
  REVISION_ID CHAR(36) NOT NULL PRIMARY KEY,
  SOLUTION_ID CHAR(36) NOT NULL,
  VERSION VARCHAR(25) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  -- MariaDB does not support JSON column type
  METADATA VARCHAR(1024) CHECK (METADATA IS NULL OR JSON_VALID(METADATA)),
  SOURCE_ID CHAR(36),
  ORIGIN VARCHAR(512),
  AUTHORS VARCHAR(1024),
  PUBLISHER VARCHAR(64),
  SV_LICENSE_CD CHAR(2),
  SV_VULNER_CD CHAR(2),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  ONBOARDED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  CONSTRAINT C_SOLUTION_REV_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_SOLUTION_REV_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID),
  CONSTRAINT C_SOLUTION_REV_C_PEER FOREIGN KEY (SOURCE_ID) REFERENCES C_PEER (PEER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- System-generated content stored in Nexus
CREATE TABLE C_ARTIFACT (
  ARTIFACT_ID CHAR(36) NOT NULL PRIMARY KEY,
  VERSION VARCHAR(25) NOT NULL,
  -- Value set restricted by type table
  ARTIFACT_TYPE_CD CHAR(2) NOT NULL,
  NAME VARCHAR(100) NOT NULL,
  DESCRIPTION VARCHAR(512),
  URI VARCHAR(512) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  SIZE INT NOT NULL,
  -- MariaDB does not support JSON column type
  METADATA VARCHAR(1024) CHECK (METADATA IS NULL OR JSON_VALID(METADATA)),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_ARTIFACT_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Many:many mapping of solution_rev to artifact requires a map (join) table
CREATE TABLE C_SOL_REV_ART_MAP (
  REVISION_ID CHAR(36) NOT NULL,
  ARTIFACT_ID CHAR(36) NOT NULL,
  PRIMARY KEY (REVISION_ID, ARTIFACT_ID),
  CONSTRAINT C_SOL_REV_ART_MAP_C_SOLUTION_REV FOREIGN KEY (REVISION_ID) REFERENCES C_SOLUTION_REV (REVISION_ID),
  CONSTRAINT C_SOL_REV_ART_MAP_C_ARTIFACT     FOREIGN KEY (ARTIFACT_ID) REFERENCES C_ARTIFACT (ARTIFACT_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Many:many mapping of solution to solution (composite) requires a map (join) table
CREATE TABLE C_COMP_SOL_MAP (
  PARENT_ID CHAR(36) NOT NULL,
  CHILD_ID CHAR(36) NOT NULL,
  PRIMARY KEY (PARENT_ID, CHILD_ID),
  CONSTRAINT C_COMP_SOL_MAP_PARENT FOREIGN KEY (PARENT_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_COMP_SOL_MAP_CHILD  FOREIGN KEY (CHILD_ID) REFERENCES C_SOLUTION (SOLUTION_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- No ID column, no created/modified columns, just a name
-- because the content is shorter than a UUID field.
CREATE TABLE C_SOLUTION_TAG (
  TAG VARCHAR(32) NOT NULL PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Many:many mapping of solution to tag requires a map (join) table
CREATE TABLE C_SOL_TAG_MAP (
  SOLUTION_ID CHAR(36) NOT NULL,
  TAG VARCHAR(32) NOT NULL,
  PRIMARY KEY (SOLUTION_ID, TAG),
  CONSTRAINT C_SOL_TAG_MAP_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_SOL_TAG_MAP_C_SOLUTION_TAG FOREIGN KEY (TAG) REFERENCES C_SOLUTION_TAG (TAG)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Many:many mapping of user to solution tag requires a map (join) table
CREATE TABLE C_USER_TAG_MAP (
  USER_ID CHAR(36) NOT NULL,
  TAG VARCHAR(32) NOT NULL,
  PRIMARY KEY (USER_ID, TAG),
  CONSTRAINT C_USER_TAG_MAP_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID),
  CONSTRAINT C_USER_TAG_MAP_C_SOL_TAG FOREIGN KEY (TAG) REFERENCES C_SOLUTION_TAG (TAG)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_SOLUTION_FAVORITE (
  SOLUTION_ID CHAR(36) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  PRIMARY KEY (SOLUTION_ID, USER_ID),
  CONSTRAINT C_SOLUTION_FAVORITE_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_SOLUTION_FAVORITE_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_SOLUTION_DOWNLOAD (
  DOWNLOAD_ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  SOLUTION_ID CHAR(36) NOT NULL,
  ARTIFACT_ID CHAR(36) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  DOWNLOAD_DATE TIMESTAMP NOT NULL,
  INDEX (SOLUTION_ID),
  CONSTRAINT C_SOLUTION_DOWNLOAD_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_SOLUTION_DOWNLOAD_C_ARTIFACT FOREIGN KEY (ARTIFACT_ID) REFERENCES C_ARTIFACT (ARTIFACT_ID),
  CONSTRAINT C_SOLUTION_DOWNLOAD_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_SOLUTION_RATING (
  SOLUTION_ID CHAR(36) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  RATING SMALLINT,
  TEXT_REVIEW VARCHAR(1024),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  PRIMARY KEY (SOLUTION_ID, USER_ID),
  CONSTRAINT C_SOLUTION_RATING_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_SOLUTION_RATING_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_NOTIFICATION (
  NOTIFICATION_ID CHAR(36) NOT NULL PRIMARY KEY,
  TITLE VARCHAR(100) NOT NULL,
  MESSAGE VARCHAR(2048),
  MSG_SEVERITY_CD CHAR(2) NOT NULL,
  URL VARCHAR(512),
  -- disable auto-update behavior with default values
  START_DATE TIMESTAMP NOT NULL DEFAULT 0,
  END_DATE TIMESTAMP NOT NULL DEFAULT 0,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Also has an attribute, not just ID columns
CREATE TABLE C_NOTIF_USER_MAP (
  NOTIFICATION_ID CHAR(36) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  -- disable auto-update behavior with default value
  VIEWED_DATE TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (NOTIFICATION_ID, USER_ID),
  CONSTRAINT C_NOTIF_USER_MAP_C_NOTIFICATION FOREIGN KEY (NOTIFICATION_ID) REFERENCES C_NOTIFICATION (NOTIFICATION_ID),
  CONSTRAINT C_NOTIF_USER_MAP_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Access control list is a many:many mapping of solution to user, requires a map (join) table
CREATE TABLE C_SOL_USER_ACCESS_MAP (
  SOLUTION_ID CHAR(36) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  PRIMARY KEY (SOLUTION_ID, USER_ID),
  CONSTRAINT C_SOL_USER_ACCESS_MAP_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_SOL_USER_ACCESS_MAP_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_SOLUTION_DEPLOYMENT (
  DEPLOYMENT_ID CHAR(36) NOT NULL PRIMARY KEY,
  SOLUTION_ID CHAR(36) NOT NULL,
  REVISION_ID CHAR(36) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  DEP_STATUS_CD CHAR(2) NOT NULL,
  TARGET VARCHAR(64),
  DETAIL VARCHAR(1024) CHECK (DETAIL IS NULL OR JSON_VALID(DETAIL)),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_SOL_DEP_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_SOL_DEP_C_REVISION FOREIGN KEY (REVISION_ID) REFERENCES C_SOLUTION_REV (REVISION_ID),
  CONSTRAINT C_SOL_DEP_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_SITE_CONFIG (
  CONFIG_KEY VARCHAR(50) NOT NULL PRIMARY KEY,
  CONFIG_VAL VARCHAR(8192) NOT NULL CHECK (JSON_VALID(CONFIG_VAL)),
  USER_ID CHAR(36) NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_SITE_CONFIG_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_THREAD (
  THREAD_ID CHAR(36) NOT NULL PRIMARY KEY,
  SOLUTION_ID CHAR(36) NOT NULL,
  REVISION_ID CHAR(36) NOT NULL,
  TITLE VARCHAR(128),
  CONSTRAINT C_THREAD_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_THREAD_C_REVISION FOREIGN KEY (REVISION_ID) REFERENCES C_SOLUTION_REV (REVISION_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_COMMENT (
  COMMENT_ID CHAR(36) NOT NULL PRIMARY KEY,
  THREAD_ID CHAR(36) NOT NULL,
  PARENT_ID CHAR(36) NULL,
  USER_ID CHAR(36) NOT NULL,
  TEXT VARCHAR(8192) NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_COMMENT_C_THREAD FOREIGN KEY (THREAD_ID) REFERENCES C_THREAD (THREAD_ID),
  CONSTRAINT C_COMMENT_C_PARENT FOREIGN KEY (PARENT_ID) REFERENCES C_COMMENT (COMMENT_ID),
  CONSTRAINT C_COMMENT_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_TASK (
  ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  TASK_CD CHAR(2) NOT NULL,
  STATUS_CD CHAR(2) NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  NAME VARCHAR(100) NOT NULL,
  TRACKING_ID CHAR(36),
  SOLUTION_ID CHAR(36),
  REVISION_ID CHAR(36),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_TASK_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID),
  CONSTRAINT C_TASK_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_TASK_C_SOLUTION_REV FOREIGN KEY (REVISION_ID) REFERENCES C_SOLUTION_REV (REVISION_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_STEP_RESULT (
  ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  TASK_ID INT NOT NULL,
  STATUS_CD CHAR(2) NOT NULL,
  NAME VARCHAR(100) NOT NULL,
  RESULT VARCHAR(8192),
  START_DATE TIMESTAMP NOT NULL DEFAULT 0,
  END_DATE TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_NOTIF_USER_PREF (
  ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  USER_ID CHAR(36) NOT NULL,
  NOTIF_DELV_MECH_CD CHAR(2) NOT NULL,
  MSG_SEVERITY_CD CHAR(2) NOT NULL,
  CONSTRAINT C_NOTIF_USER_PREF_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_REV_CAT_DESC (
  REVISION_ID CHAR(36) NOT NULL,
  CATALOG_ID CHAR(36) NOT NULL,
  DESCRIPTION LONGTEXT NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  PRIMARY KEY (REVISION_ID, CATALOG_ID),
  CONSTRAINT C_REV_CAT_DESC_C_REVISION FOREIGN KEY (REVISION_ID) REFERENCES C_SOLUTION_REV (REVISION_ID),
  CONSTRAINT C_REV_CAT_DESC_C_CATALOG FOREIGN KEY (CATALOG_ID) REFERENCES C_CATALOG (CATALOG_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- User-generated content stored in Nexus
CREATE TABLE C_DOCUMENT (
  DOCUMENT_ID CHAR(36) NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL,
  URI VARCHAR(512) NOT NULL,
  VERSION VARCHAR(25),
  SIZE INT NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_DOCUMENT_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Many:many mapping of revision and catalog to document requires a map (join) table
CREATE TABLE C_REV_CAT_DOC_MAP (
  REVISION_ID CHAR(36) NOT NULL,
  CATALOG_ID CHAR(36) NOT NULL,
  DOCUMENT_ID CHAR(36) NOT NULL,
  PRIMARY KEY (REVISION_ID, CATALOG_ID, DOCUMENT_ID),
  CONSTRAINT C_REV_CAT_DOC_MAP_C_SOLUTION_REV FOREIGN KEY (REVISION_ID) REFERENCES C_SOLUTION_REV (REVISION_ID),
  CONSTRAINT C_REV_CAT_DOC_MAP_C_CATALOG FOREIGN KEY (CATALOG_ID) REFERENCES C_CATALOG (CATALOG_ID),
  CONSTRAINT C_REV_CAT_DOC_MAP_C_REV_DOC FOREIGN KEY (DOCUMENT_ID) REFERENCES C_DOCUMENT (DOCUMENT_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_SITE_CONTENT (
  CONTENT_KEY VARCHAR(50) NOT NULL PRIMARY KEY,
  CONTENT_VAL LONGBLOB NOT NULL,
  MIME_TYPE VARCHAR(50) NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_CAT_SOL_MAP (
  CATALOG_ID CHAR(36) NOT NULL,
  SOLUTION_ID CHAR(36) NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  PRIMARY KEY (CATALOG_ID, SOLUTION_ID),
  CONSTRAINT C_CAT_SOL_MAP_C_CATALOG FOREIGN KEY (CATALOG_ID) REFERENCES C_CATALOG (CATALOG_ID),
  CONSTRAINT C_CAT_SOL_MAP_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Tracks publish-to-public workflow requests
CREATE TABLE C_PUBLISH_REQUEST (
  REQUEST_ID INT PRIMARY KEY AUTO_INCREMENT,
  SOLUTION_ID CHAR(36) NOT NULL,
  REVISION_ID CHAR(36) NOT NULL,
  CATALOG_ID CHAR(36) NOT NULL,
  REQ_USER_ID CHAR(36) NOT NULL,
  RVW_USER_ID CHAR(36),
  STATUS_CD CHAR(2) NOT NULL,
  COMMENT VARCHAR(8192),
  CONSTRAINT C_PUB_REQ_C_SOLUTION FOREIGN KEY (SOLUTION_ID) REFERENCES C_SOLUTION (SOLUTION_ID),
  CONSTRAINT C_PUB_REQ_C_REVISION FOREIGN KEY (REVISION_ID) REFERENCES C_SOLUTION_REV (REVISION_ID),
  CONSTRAINT C_PUB_REQ_C_CATALOG FOREIGN KEY (CATALOG_ID) REFERENCES C_CATALOG (CATALOG_ID),
  CONSTRAINT C_PUB_REQ_REQ_C_USER FOREIGN KEY (REQ_USER_ID) REFERENCES C_USER (USER_ID),
  CONSTRAINT C_PUB_REQ_APP_C_USER FOREIGN KEY (RVW_USER_ID) REFERENCES C_USER (USER_ID),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_NOTEBOOK (
  NOTEBOOK_ID CHAR(36) NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL,
  ACTIVE_YN CHAR(1) DEFAULT 'Y' NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  VERSION VARCHAR(25) NOT NULL,
  NOTEBOOK_TYPE_CD CHAR(2) NOT NULL,
  KERNEL_TYPE_CD CHAR(2),
  DESCRIPTION VARCHAR(1024),
  SERVICE_STATUS_CD CHAR(2),
  REPOSITORY_URL VARCHAR(512),
  SERVICE_URL VARCHAR(512),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_NOTEBOOK_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_PROJECT (
  PROJECT_ID CHAR(36) NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL,
  ACTIVE_YN CHAR(1) DEFAULT 'Y' NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  VERSION VARCHAR(25) NOT NULL,
  DESCRIPTION VARCHAR(1024),
  SERVICE_STATUS_CD CHAR(2),
  REPOSITORY_URL VARCHAR(512),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_PROJECT_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_PIPELINE (
  PIPELINE_ID CHAR(36) NOT NULL PRIMARY KEY,
  NAME VARCHAR(100) NOT NULL,
  ACTIVE_YN CHAR(1) DEFAULT 'Y' NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  VERSION VARCHAR(25) NOT NULL,
  DESCRIPTION VARCHAR(1024),
  SERVICE_STATUS_CD CHAR(2),
  REPOSITORY_URL VARCHAR(512),
  SERVICE_URL VARCHAR(512),
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_PIPELINE_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_PROJ_NB_MAP (
  PROJECT_ID CHAR(36) NOT NULL,
  NOTEBOOK_ID CHAR(36) NOT NULL,
  PRIMARY KEY (PROJECT_ID, NOTEBOOK_ID),
  CONSTRAINT C_PROJ_NB_MAP_C_PROJECT FOREIGN KEY (PROJECT_ID) REFERENCES C_PROJECT (PROJECT_ID),
  CONSTRAINT C_PROJ_NB_MAP_C_NOTEBOOK FOREIGN KEY (NOTEBOOK_ID) REFERENCES C_NOTEBOOK (NOTEBOOK_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_PROJ_PL_MAP (
  PROJECT_ID CHAR(36) NOT NULL,
  PIPELINE_ID CHAR(36) NOT NULL,
  PRIMARY KEY (PROJECT_ID, PIPELINE_ID),
  CONSTRAINT C_PROJ_PL_MAP_C_PROJECT FOREIGN KEY (PROJECT_ID) REFERENCES C_PROJECT (PROJECT_ID),
  CONSTRAINT C_PROJ_PL_MAP_C_PIPELINE FOREIGN KEY (PIPELINE_ID) REFERENCES C_PIPELINE (PIPELINE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_PEER_CAT_ACC_MAP (
  PEER_ID CHAR(36) NOT NULL,
  CATALOG_ID CHAR(36) NOT NULL,
  PRIMARY KEY (PEER_ID, CATALOG_ID),
  CONSTRAINT C_PEER_CAT_ACC_MAP_C_PEER FOREIGN KEY (PEER_ID) REFERENCES C_PEER (PEER_ID),
  CONSTRAINT C_PEER_CAT_ACC_MAP_C_CATALOG FOREIGN KEY (CATALOG_ID) REFERENCES C_CATALOG (CATALOG_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_USER_CAT_FAV_MAP (
  USER_ID CHAR(36) NOT NULL,
  CATALOG_ID CHAR(36) NOT NULL,
  PRIMARY KEY (USER_ID, CATALOG_ID),
  CONSTRAINT C_USER_CAT_FAV_MAP_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID),
  CONSTRAINT C_USER_CAT_FAV_MAP_C_CATALOG FOREIGN KEY (CATALOG_ID) REFERENCES C_CATALOG (CATALOG_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_LICENSE_PROFILE_TEMPLATE (
  TEMPLATE_ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  TEMPLATE_NAME VARCHAR(50) NOT NULL,
  TEMPLATE VARCHAR(8192) NOT NULL CHECK (JSON_VALID(TEMPLATE)),
  PRIORITY INT NOT NULL,
  USER_ID CHAR(36) NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL DEFAULT 0,
  MODIFIED_DATE TIMESTAMP NOT NULL,
  CONSTRAINT C_LICENSE_PROFILE_TEMPLATE_C_USER FOREIGN KEY (USER_ID) REFERENCES C_USER (USER_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE C_CAT_ROLE_MAP (
  CATALOG_ID CHAR(36) NOT NULL,
  ROLE_ID CHAR(36) NOT NULL,
  PRIMARY KEY (CATALOG_ID, ROLE_ID),
  CONSTRAINT FK_C_CAT_ROLE_MAP_C_CATALOG FOREIGN KEY (CATALOG_ID) REFERENCES C_CATALOG (CATALOG_ID),
  CONSTRAINT FK_C_CAT_ROLE_MAP_C_ROLE FOREIGN KEY (ROLE_ID) REFERENCES C_ROLE (ROLE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- For tracking create/upgrade/downgrade; no Java entity
CREATE TABLE C_HISTORY (
  ID INT PRIMARY KEY AUTO_INCREMENT,
  COMMENT VARCHAR(100) NOT NULL,
  CREATED_DATE TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- DML --

# Base roles; names are case sensitive
INSERT INTO C_ROLE (ROLE_ID, NAME, ACTIVE_YN, CREATED_DATE, MODIFIED_DATE) VALUES ('12345678-abcd-90ab-cdef-1234567890ab', 'MLP System User', 'Y', NOW(), NOW());
INSERT INTO C_ROLE (ROLE_ID, NAME, ACTIVE_YN, CREATED_DATE, MODIFIED_DATE) VALUES ('8c850f07-4352-4afd-98b1-00cbceca569f', 'Admin', 'Y', NOW(), NOW());
INSERT INTO C_ROLE (ROLE_ID, NAME, ACTIVE_YN, CREATED_DATE, MODIFIED_DATE) VALUES ('9d961018-5464-5b0e-a9c2-11dcdfdb67a0', 'Publisher', 'Y', NOW(), NOW());

-- Base admin user
INSERT INTO C_USER (USER_ID, LOGIN_NAME, LOGIN_HASH, FIRST_NAME, LAST_NAME, EMAIL, CREATED_DATE, MODIFIED_DATE) VALUES ('12345678-abcd-90ab-cdef-1234567890ab', 'admin', '$2a$10$nogCM69/Vc0rEsZbHXlEm.nxSdGuD88Kd6NlW6fnKJz3AIz0PdOwa', 'Acumos', 'Admin', 'noreply@acumos.org', NOW(), NOW());

-- Grant all roles to admin user
INSERT INTO C_USER_ROLE_MAP (USER_ID, ROLE_ID) VALUES ('12345678-abcd-90ab-cdef-1234567890ab', '8c850f07-4352-4afd-98b1-00cbceca569f');
INSERT INTO C_USER_ROLE_MAP (USER_ID, ROLE_ID) VALUES ('12345678-abcd-90ab-cdef-1234567890ab', '9d961018-5464-5b0e-a9c2-11dcdfdb67a0');

-- Create two catalogs
INSERT INTO C_CATALOG (CATALOG_ID, ACCESS_TYPE_CD, SELF_PUBLISH_YN, NAME, PUBLISHER, URL, CREATED_DATE, MODIFIED_DATE) VALUES
  (UUID(), 'PB', 'N', 'Public Models',  'My Company', 'http://catalog.my.org/public',  NOW(), NOW()),
  (UUID(), 'RS', 'Y', 'Company Models', 'My Company', 'http://catalog.my.org/company', NOW(), NOW());

-- Default configuration of Portal/Marketplace features.
-- Unfortunately JSON does not allow embedded newlines.
INSERT INTO C_SITE_CONFIG (CONFIG_KEY, CONFIG_VAL, CREATED_DATE, MODIFIED_DATE) VALUES
  ('carousel_config', '{"0":{"name":"We are Moving to a Future where AI is at the Center of Software.","headline":"Welcome to Acumos!","supportingContent":"<p>Acumos is the open-source framework for data scientists to build that future.</p>","textAling":"left","graphicImgEnabled":false,"number":"0","slideEnabled":"true","uniqueKey":3,"bgImgKey":"carousel.top.1.bgImg","infoImgKey":"carousel.top.1.infoImg","hasInfoGraphic":false,"links":{"enableLink":true,"primary":{"label":"Marketplace","address":"marketPlace"},"secondary":{"label":"Onboard Model","address":"modelerResource"}}}}', NOW(), NOW()),
  ('local_validation_workflow', '{"ignore_list":[]}', NOW(), NOW()),
  ('public_validation_workflow', '{"ignore_list":["Text Check"]}', NOW(), NOW()),
  ('site_config', '{"fields":[{"type":"text","name":"siteInstanceName","label":"Site Instance Name","required":"true","data":"Acumos"}, {"type":"heading","name":"ConnectionConfig","label":"Connection Configuration","required":"true","subFields":[{"type":"text","name":"socketTimeout","label":"Socket Timeout","required":"true","data":"300"},{"type":"text","name":"connectionTimeout","label":"Connection Timeout","required":"true","data":"10"}]},{"type":"select","name":"enableOnBoarding","label":"Enable On-Boarding","options":[{"name":"Enabled"},{"name":"Disabled"}],"required":true,"data":{"name":"Enabled"}},{"type":"select","name":"EnableDCAE","label":"Enable DCAE","options":[{"name":"Enabled"},{"name":"Disabled"}],"required":true,"data":{"name":"Disabled"}}]}', NOW(), NOW());
-- The long image line gives some editors trouble
INSERT INTO C_SITE_CONTENT (CONTENT_KEY, CONTENT_VAL, MIME_TYPE, CREATED_DATE, MODIFIED_DATE) VALUES
  ('global.discoverAcumos.marketPlace','<h5>Marketplace</h5><p>Acumos is the go-to site for data-powered decision making. With an intuitive easy-to-use Marketplace and Design Studio, Acumos brings AI into the mainstream.</p>','text/plain', NOW(), NOW()),
  ('global.discoverAcumos.designStudio','<h5>Design Studio</h5><p>Because Acumos converts models to microservices, you can apply them to different problems and data sources.</p>','text/plain', NOW(), NOW()),
  ('global.discoverAcumos.sdnOnap','<h5>SDN &amp; ONAP</h5><p>Many Marketplace solutions originated in the ONAP SDN community and are configured to be directly deployed to SDC.</p>','text/plain', NOW(),NOW()),
  ('global.discoverAcumos.preferredToolkit','<h5>On-Board with your Preferred Toolkit</h5><p>With a focus on interoperability, Acumos supports diverse Al toolkits. Onboarding tools are available for TensorFlow, SciKitLearn, RCloud,  H2O and generic Java.</p>','text/plain', NOW(), NOW()),
  ('global.discoverAcumos.teamUp','<h5>Team Up!</h5><p>Share, experiment and collaborate in an open source ecosystem of people, solutions and ideas.</p>','text/plain', NOW(), NOW()),
  ('global.footer.contactInfo','<p>Please enter your team\'s contact details using the Site Admin, Site Content feature of Portal.</p>','text/html', NOW(), NOW()),
  ('global.termsConditions','<p>Please enter your organization\'s terms and conditions using the Site Admin, Site Content feature of Portal.</p>','text/html', NOW(), NOW());

-- Create license profile templates
INSERT INTO C_LICENSE_PROFILE_TEMPLATE (TEMPLATE_NAME, PRIORITY, USER_ID, CREATED_DATE, MODIFIED_DATE, TEMPLATE) VALUES
 ('Apache-2.0', 0, '12345678-abcd-90ab-cdef-1234567890ab', NOW(), NOW(), '{ "$schema": "https://raw.githubusercontent.com/acumos/license-manager/master/license-manager-client-library/src/main/resources/schema/1.0.0/license-profile.json", "keyword": "Apache-2.0", "licenseName": "Apache License 2.0", "copyright": { "year": 2019, "company": "Company A", "suffix": "All Rights Reserved" }, "softwareType": "Machine Learning Model", "companyName": "Company A", "contact": { "name": "Company A Team Member", "URL": "http://companya.com", "email": "support@companya.com" }, "rtuRequired": false}'),
 ('Vendor-A-OSS', 1, '12345678-abcd-90ab-cdef-1234567890ab', NOW(), NOW(), '{ "$schema": "https://raw.githubusercontent.com/acumos/license-manager/master/license-manager-client-library/src/main/resources/schema/1.0.0/license-profile.json", "keyword": "Vendor-A-OSS", "licenseName": "Vendor A Open Source Software License", "copyright": { "year": 2019, "company": "Vendor A", "suffix": "All Rights Reserved" }, "softwareType": "Machine Learning Model", "companyName": "Vendor A", "contact": { "name": "Vendor A Team", "URL": "http://Vendor-A.com", "email": "support@Vendor-A.com" }, "additionalInfo": "http://Vendor-A.com/licenses/Vendor-A-OSS", "rtuRequired": true}'),
 ('Company-B-Proprietary', 2, '12345678-abcd-90ab-cdef-1234567890ab', NOW(), NOW(), '{ "$schema": "https://raw.githubusercontent.com/acumos/license-manager/master/license-manager-client-library/src/main/resources/schema/1.0.0/license-profile.json", "keyword": "Company-B-Proprietary", "licenseName": "Company B Proprietary License", "copyright": { "year": 2019, "company": "Company B", "suffix": "All Rights Reserved" }, "softwareType": "Machine Learning Model", "companyName": "Company B", "contact": { "name": "Company B Team Member", "URL": "http://Company-B.com", "email": "support@Company-B.com" }, "additionalInfo": "http://Company-B.com/licenses/Company-B-Proprietary", "rtuRequired": true}');

-- Record this action in the history
INSERT INTO C_HISTORY (COMMENT, CREATED_DATE) VALUES ('cmn-data-svc-ddl-dml-3.1-rev1', NOW());
