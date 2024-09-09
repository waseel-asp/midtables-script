ALTER TABLE NPHIES_BENEFICIARY ADD (
OCCUPATION VARCHAR2(20) NULL,
RELIGION VARCHAR2(5)
);

ALTER TABLE NPHIES_CLAIMDIAGNOSIS ADD (
CONDITIONONSET VARCHAR2(10));

ALTER TABLE NPHIES_CLAIMITEM ADD (
ISMATERNITY VARCHAR2(10) NULL);


Create table NPHIES_COVERAGE_CLASS (
	COVERAGECLASSID VARCHAR2 (20) NOT NULL,
	TYPE VARCHAR2 (50) NOT NULL,
	VALUE VARCHAR2 (250) NOT NULL,
	NAME VARCHAR2(250),
	COVERAGEID VARCHAR2(20) NOT NULL,
 Constraint PK_COVERAGE_CLASS primary key (COVERAGECLASSID)
);

Alter table NPHIES_COVERAGE_CLASS add Constraint FK_BENEFICIARY_COVERAGE_CLASS foreign key (COVERAGEID) references NPHIES_COVERAGE (COVERAGEID);

Alter table NPHIES_CLAIMENCOUNTERS DROP COLUMN HOSPITALADMISSIONSPECIALITY;
Alter table NPHIES_CLAIMENCOUNTERS DROP COLUMN HOSPITALDISCHARGESPECIALITY;
Alter table NPHIES_CLAIMENCOUNTERS DROP COLUMN HOSPITALINTENDEDLENGTHOFSTAY;
Alter table NPHIES_CLAIMENCOUNTERS DROP COLUMN HOSPITALIZATIONORIGIN;
Alter table NPHIES_CLAIMENCOUNTERS DROP COLUMN HOSPITALADMISSIONSOURCE;
Alter table NPHIES_CLAIMENCOUNTERS DROP COLUMN HOSPITALREADMISSION;
Alter table NPHIES_CLAIMENCOUNTERS DROP COLUMN HOSPITALDISCHARGEDISPOSITION;

ALTER TABLE NPHIES_CLAIMENCOUNTERS ADD (
CAUSEOFDEATH VARCHAR2(10) NULL,
SERVICEEVENTTYPE VARCHAR2(10) NULL
);
Alter table NPHIES_CLAIMENCOUNTERS add Constraint UNIQUE_CLAIMENCOUNTERS unique (ENCOUNTERID);

Create table NPHIESENCOUNTERHOSPITALIZATION (
	ENCOUNTERHOSPITALIZATIONID VARCHAR2 (20) NOT NULL,
	HOSPITALADMISSIONSPECIALITY VARCHAR2(20) NOT NULL,
    HOSPITALDISCHARGESPECIALITY VARCHAR2(20),
    HOSPITALINTENDEDLENGTHOFSTAY VARCHAR2(20) NOT NULL,
    HOSPITALIZATIONORIGIN VARCHAR2(20),
    HOSPITALADMISSIONSOURCE VARCHAR2(20) NOT NULL,
    HOSPITALREADMISSION VARCHAR2(20),
    HOSPITALDISCHARGEDISPOSITION VARCHAR2(20),
	ENCOUNTERID VARCHAR2(20) NOT NULL,
 Constraint PK_ENCOUNTERHOSPITALIZATION primary key (ENCOUNTERHOSPITALIZATIONID)
);

Alter table NPHIESENCOUNTERHOSPITALIZATION add Constraint FK_ENCOUNTERHOSPITALIZATION foreign key (ENCOUNTERID) references NPHIES_CLAIMENCOUNTERS (ENCOUNTERID);


Create table NPHIES_ENCOUNTEREMERGENCY (
	ENCOUNTEREMERGENCYID VARCHAR2 (20) NOT NULL,
	EMERGENCYARRIVALCODE VARCHAR2(20) NOT NULL,
	EMERGENCYSERVICESTART DATE NOT NULL,
	EMERGENCYDEPARTMENTDISPOSITION VARCHAR2(20),
	TRIAGECATEGORY VARCHAR2(20) NOT NULL,
	TRIAGEDATE DATE NOT NULL,
	ENCOUNTERID VARCHAR2(20) NOT NULL,
 Constraint PK_ENCOUNTEREMERGENCY primary key (ENCOUNTEREMERGENCYID)
);

Alter table NPHIES_ENCOUNTEREMERGENCY add Constraint FK_ENCOUNTERMERGENCY foreign key (ENCOUNTERID) references NPHIES_CLAIMENCOUNTERS (ENCOUNTERID);