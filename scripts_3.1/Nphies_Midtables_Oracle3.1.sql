

-- Create Tables section

Create table NPHIES_BENEFICIARY (
	BENEFICIARYID VARCHAR2 (20) NOT NULL,
	PATIENTFILENO VARCHAR2(30) NOT NULL,
	FIRSTNAME VARCHAR2 (50),
	MIDDLENAME VARCHAR2 (50),
	LASTNAME VARCHAR2 (50),
	FULLNAME VARCHAR2 (200),
	DOB DATE NOT NULL,
	GENDER VARCHAR2(10) NOT NULL,
	NATIONALITY VARCHAR2(30),
	DOCUMENTTYPE VARCHAR2(30) NOT NULL,
	DOCUMENTID VARCHAR2(50) NOT NULL,
	CONTACTNUMBER VARCHAR2(50),
	EHEALTHID VARCHAR2(50),
	RESIDENCYTYPE VARCHAR2(50),
	MARITALSTATUS VARCHAR2(10) NOT NULL,
	BLOODGROUP VARCHAR2(10),
	PREFERREDLANGUAGE VARCHAR2(20),
	EMAIL VARCHAR2(50),
	ADDRESSLINE VARCHAR2(250),
	ADDRESSSTREETNAME VARCHAR2(250),
	ADDRESSCITY VARCHAR2(250),
	ADDRESSDISTRICT VARCHAR2(250),
	ADDRESSSTATE VARCHAR2(250),
	ADDRESSPOSTALCODE VARCHAR2(100),
	ADDRESSCOUNTRY VARCHAR2(250),
	OCCUPATION VARCHAR2(20) NOT NULL,
	RELIGION VARCHAR2(5),
 Constraint PK_BENEFICIARY primary key (BENEFICIARYID));

Create table NPHIES_COVERAGE (
	COVERAGEID VARCHAR2 (20) NOT NULL,
	MEMBERID VARCHAR2 (50) NOT NULL,
	EXPIRYDATE DATE,
	PAYERNPHIESID VARCHAR2(20) NOT NULL,
	TPANPHIESID VARCHAR2(20) NULL,
	RELATIONWITHSUBSCRIBER VARCHAR2(20) NOT NULL,
	POLICYNUMBER VARCHAR2(30),
	POLICYHOLDER VARCHAR2(250) NOT NULL,
	COVERAGETYPE VARCHAR2(20) NOT NULL,
	BENEFICIARYID VARCHAR2(20) NOT NULL,
 Constraint PK_COVERAGE primary key (COVERAGEID) 
);

Alter table NPHIES_COVERAGE add Constraint FK_BENEFICIARY_COVERAGE foreign key (BENEFICIARYID) references NPHIES_BENEFICIARY (BENEFICIARYID);

Create table NPHIES_COVERAGE_CLASS (
	COVERAGECLASSID VARCHAR2 (20) NOT NULL,
	TYPE VARCHAR2 (50) NOT NULL,
	VALUE VARCHAR2 (250) NOT NULL,
	NAME VARCHAR2(250),
	COVERAGEID VARCHAR2(20) NOT NULL,
 Constraint PK_COVERAGE_CLASS primary key (COVERAGECLASSID)
);

Alter table NPHIES_COVERAGE_CLASS add Constraint FK_BENEFICIARY_COVERAGE_CLASS foreign key (COVERAGEID) references NPHIES_COVERAGE (COVERAGEID);


Create table NPHIES_CLAIMINFO (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	EPISODEID VARCHAR2(40) NOT NULL,
	ISNEWBORN VARCHAR2(10) DEFAULT NULL,
	ISREFERRAL VARCHAR2(10) DEFAULT NULL,
	REFERRINGPROVIDERNAME VARCHAR2 (200) DEFAULT NULL,
	CLAIMTYPE VARCHAR2(20) NOT NULL,
	CLAIMSUBTYPE VARCHAR2(20) NOT NULL,
	PROVIDERNPHIESID VARCHAR2(20) NOT NULL,
	CLAIMCREATEDDATE DATE NOT NULL,
	ACCOUNTINGPERIOD DATE NOT NULL,
	BILLABLEPERIODSTART DATE,
	BILLABLEPERIODEND DATE,
	ELIGIBILITYRESPONSEID VARCHAR2(30),
	ELIGIBILITYIDENTIFIERURL VARCHAR2(250) DEFAULT NULL,
	ELIGIBILITYOFFLINEID VARCHAR2(30),
	ELIGIBILITYOFFLINEDATE DATE,
	PREAUTHOFFLINEDATE DATE,
	PREAUTHRESPONSEID VARCHAR2(30),
	PREAUTHIDENTIFIERURL VARCHAR2(250) DEFAULT NULL,
	PAYEETYPE VARCHAR2(10),
	PAYEEID VARCHAR2(20),
	COVERAGEID VARCHAR2 (20) NOT NULL,
	BENEFICIARYID VARCHAR2(20) NOT NULL,
	SUBSCRIBERID VARCHAR2(20) NULL,
	TOTAL Decimal(14,2) NOT NULL,
	PRESCRIPTION VARCHAR(255),
 Constraint PK_CLAIMINFO primary key (PROVCLAIMNO)
);

Alter table NPHIES_CLAIMINFO add Constraint FK_BENEFICIARY_CLAIMINFO foreign key (BENEFICIARYID) references NPHIES_BENEFICIARY (BENEFICIARYID);
Alter table NPHIES_CLAIMINFO add Constraint FK_BENEFI_SUBSCRIB_CLAIMINFO foreign key (SUBSCRIBERID) references NPHIES_BENEFICIARY (BENEFICIARYID);
Alter table NPHIES_CLAIMINFO add Constraint FK_COVERAGE_CLAIMINFO foreign key (COVERAGEID) references NPHIES_COVERAGE (COVERAGEID);

Create table NPHIES_CLAIMPREAUTHDETAILS (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	PREAUTHREFNO VARCHAR2(20) NOT NULL,
	Constraint PK_CLAIMPREAUTHDETAILS primary key (PROVCLAIMNO,PREAUTHREFNO) 
);

Alter table NPHIES_CLAIMPREAUTHDETAILS add Constraint FK_CLAIMPREAUTH foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

Create table NPHIES_CLAIMDIAGNOSIS (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	SEQUENCENO INTEGER NOT NULL,
	DIAGNOSISCODE Varchar2 (30) NOT NULL,
	DIAGNOSISDESC Varchar2 (256),
	DIAGNOSISTYPE VARCHAR2(30),
	ONADMISSION VARCHAR2(10),
	CONDITIONONSET VARCHAR2(10),
 Constraint PK_CLAIMDIAGNOSIS primary key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMDIAGNOSIS add Constraint FK_CLAIMDIAGNOSIS foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

Create table NPHIES_CLAIMCARETEAM (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	SEQUENCENO INTEGER NOT NULL,
	PHYSICIANID VARCHAR2(30) NOT NULL,
	PHYSICIANNAME VARCHAR2(60) NOT NULL,
	PRACTITIONERROLE VARCHAR2(20),
	CARETEAMROLE VARCHAR2(20),
	CARETEAMQUALIFICATION VARCHAR2(30) NOT NULL,
 Constraint PK_CLAIMCARETEAM primary key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMCARETEAM add Constraint FK_CLAIMCARETEAM foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

Create table NPHIES_CLAIMITEM (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	INVOICENO VARCHAR2(30) NOT NULL,
	SEQUENCENO INTEGER NOT NULL,
	SERVICETYPE VARCHAR2(30) NOT NULL,
	SERVICECODE VARCHAR2(30) NOT NULL,
	SERVICEDESC VARCHAR2(256) NOT NULL,
	NONSTANDARDCODE VARCHAR2(30),
	NONSTANDARDDESC VARCHAR2(256),
	UDI VARCHAR2(30),
	ISPACKAGE VARCHAR2(5) NOT NULL,
	QUANTITY Decimal(10,2) NOT NULL,
	QUANTITYCODE VARCHAR2(10) NULL,
	UNITPRICE Decimal(14,2) NOT NULL,
	DISCOUNT Decimal(14,2) NULL,
	FACTOR Decimal(14,6) NOT NULL,
	PATIENTSHARE Decimal(14,2) NOT NULL,
	PAYERSHARE Decimal(14,2) NOT NULL,
	TAX Decimal(14,2) NOT NULL,
	NET Decimal(14,2) NOT NULL,
	STARTDATE DATE NULL,
	ENDDATE DATE NOT NULL,
	BODYSITECODE VARCHAR2(10),
	SUBSITECODE VARCHAR2(10),
	DRUGSELECTIONREASON VARCHAR2(30),
	PRESCRIBEDDRUGCODE VARCHAR2(50),
	PHARMACISTSELECTIONREASON  VARCHAR(255) ,
	PHARMACISTSUBSTITUTE VARCHAR(255),
	REASONPHARMACISTSUBSTITUTE VARCHAR(255),
	ISMATERNITY VARCHAR2(10) DEFAULT NULL,
 Constraint PK_CLAIMITEM primary key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMITEM add Constraint FK_CLAIMITEM foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

Create table NPHIES_CLAIMSUPPORTINGINFO (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	SEQUENCENO INTEGER NOT NULL,
	CATEGORY VARCHAR2(20) NOT NULL,
	REASON VARCHAR2(20),
	SUPPORTINGVALUE VARCHAR2(2000),
	SUPPORTINGATTACHMENT BLOB,
	ATTACHMENTFILENAME VARCHAR2(30),
	ATTACHMENTTYPE VARCHAR2(20),
	CODE VARCHAR2(30),
	UNIT VARCHAR2(30) DEFAULT NULL,
	TIMINGPERIODFROM DATE DEFAULT NULL,
	TIMINGPERIODTO DATE DEFAULT NULL,
 Constraint PK_CLAIMSUPPORTINGINFO primary key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMSUPPORTINGINFO add Constraint FK_CLAIMSUPPORTINGINFO foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

Create table NPHIES_CLAIMACCIDENTDETAIL (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	ACCIDENTTYPE VARCHAR2(20) NOT NULL,
	ACCIDENTDATE DATE NOT NULL,
	ADDRESSSTREETNAME  VARCHAR2(250),
	ADDRESSCITY VARCHAR2(250),
	ADDRESSSTATE VARCHAR2(250),
	ADDRESSCOUNTRY VARCHAR2(250),
 Constraint PK_CLAIMACCIDENTDETAIL primary key (PROVCLAIMNO)
);

Alter table NPHIES_CLAIMACCIDENTDETAIL add Constraint FK_CLAIMACCIDENTDETAIL foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);

Create table NPHIES_CLAIMVISIONPRESCRIPTION (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	VISIONPRESCRIPTIONID VARCHAR2 (20) NOT NULL,
	DATEWRITTEN DATE NOT NULL,
	CARETEAMSEQUENCE INTEGER NOT NULL,
	PRODUCT VARCHAR2(10) NOT NULL,
	EYE VARCHAR2(10) NOT NULL,
	SPHERE Decimal(14,2),
	CYLINDER Decimal(14,2),
	AXIS INTEGER,
	PRISMAMOUNT Decimal(14,2),
	PRISMBASE VARCHAR2(10),
	MULTIFOCALPOWER Decimal(14,2),
	LENSPOWER Decimal(14,2),
	LENSBACKCURVE Decimal(14,2),
	LENSDIAMETER Decimal(14,2),
	LENSDURATION INTEGER,
	LENSCOLOR VARCHAR2(10),
	LENSBRAND VARCHAR2(50),
	LENSNOTE VARCHAR2(256),
	LENSDURATIONUNIT VARCHAR2(10),
 Constraint PK_CLAIMVISIONPRESCRIPTION primary key (PROVCLAIMNO,VISIONPRESCRIPTIONID)
);

Alter table NPHIES_CLAIMVISIONPRESCRIPTION add Constraint FK_CLAIMVISIONPRESCRIPTION foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_CLAIMVISIONPRESCRIPTION add Constraint FK_CARETEAMVISION foreign key (PROVCLAIMNO,CARETEAMSEQUENCE) references NPHIES_CLAIMCARETEAM (PROVCLAIMNO,SEQUENCENO);

Create table NPHIES_ITEMDIAGNOSIS (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	DIAGNOSISSEQUENCENO INTEGER NOT NULL,
	ITEMSEQUENCENO INTEGER NOT NULL,
 Constraint PK_ITEMDIAGNOSIS primary key (PROVCLAIMNO,DIAGNOSISSEQUENCENO,ITEMSEQUENCENO)
);

Alter table NPHIES_ITEMDIAGNOSIS add Constraint FK_ITEMDIAGNOSIS foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_ITEMDIAGNOSIS add Constraint FK_DIAGNOSISSEQ foreign key (PROVCLAIMNO,DIAGNOSISSEQUENCENO) references NPHIES_CLAIMDIAGNOSIS (PROVCLAIMNO,SEQUENCENO);
Alter table NPHIES_ITEMDIAGNOSIS add Constraint FK_ITEMDIASEQ foreign key (PROVCLAIMNO,ITEMSEQUENCENO) references NPHIES_CLAIMITEM (PROVCLAIMNO,SEQUENCENO);

Create table NPHIES_ITEMCARETEAM (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	CARETEAMSEQUENCENO INTEGER NOT NULL,
	ITEMSEQUENCENO INTEGER NOT NULL,
 Constraint PK_ITEMCARETEAM primary key (PROVCLAIMNO,CARETEAMSEQUENCENO,ITEMSEQUENCENO)
);

Alter table NPHIES_ITEMCARETEAM add Constraint FK_ITEMCARETEAM foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_ITEMCARETEAM add Constraint FK_CARETEAMSEQ foreign key (PROVCLAIMNO,CARETEAMSEQUENCENO) references NPHIES_CLAIMCARETEAM (PROVCLAIMNO,SEQUENCENO);
Alter table NPHIES_ITEMCARETEAM add Constraint FK_ITEMCARESEQ foreign key (PROVCLAIMNO,ITEMSEQUENCENO) references NPHIES_CLAIMITEM (PROVCLAIMNO,SEQUENCENO);

Create table NPHIES_ITEMSUPPORTINGINFO (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	SUPPORTINGINFOSEQUENCENO INTEGER NOT NULL,
	ITEMSEQUENCENO INTEGER NOT NULL,
 Constraint PK_ITEMSUPPORTINGINFO primary key (PROVCLAIMNO,SUPPORTINGINFOSEQUENCENO,ITEMSEQUENCENO)
);

Alter table NPHIES_ITEMSUPPORTINGINFO add Constraint FK_ITEMSUPPORTINGINFO foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
Alter table NPHIES_ITEMSUPPORTINGINFO add Constraint FK_SUPPORTINGINFOSEQ foreign key (PROVCLAIMNO,SUPPORTINGINFOSEQUENCENO) references NPHIES_CLAIMSUPPORTINGINFO (PROVCLAIMNO,SEQUENCENO);
Alter table NPHIES_ITEMSUPPORTINGINFO add Constraint FK_ITEMSUPPORTINGSEQ foreign key (PROVCLAIMNO,ITEMSEQUENCENO) references NPHIES_CLAIMITEM (PROVCLAIMNO,SEQUENCENO);

Create table NPHIES_CLAIMITEMDETAILS (
	ITEMSEQUENCENO INTEGER NOT NULL,
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	SEQUENCENO INTEGER NOT NULL,
	SERVICETYPE VARCHAR2(30) NOT NULL,
	SERVICECODE VARCHAR2(30) NOT NULL,
	SERVICEDESC VARCHAR2(256) NOT NULL,
	NONSTANDARDCODE VARCHAR2(30),
	NONSTANDARDDESC VARCHAR2(256),
	UDI VARCHAR2(30),
	QUANTITY Decimal(10,2) NOT NULL,
	QUANTITYCODE VARCHAR2(10) NULL,
	UNITPRICE Decimal(14,2),
	TAX Decimal(14,2),
	NET Decimal(14,2),
	PHARMACISTSELECTIONREASON  VARCHAR(255) ,
	PHARMACISTSUBSTITUTE VARCHAR(255),
	REASONPHARMACISTSUBSTITUTE VARCHAR(255),
	PRESCRIBEDDRUGCODE VARCHAR2(50),
 Constraint PK_CLAIMITEMDETAILS primary key (PROVCLAIMNO,SEQUENCENO)
);

Alter table NPHIES_CLAIMITEMDETAILS add Constraint FK_ITEMDETAILSSEQ foreign key (PROVCLAIMNO,ITEMSEQUENCENO) references NPHIES_CLAIMITEM (PROVCLAIMNO,SEQUENCENO);

Create table NPHIES_CLAIMENCOUNTERS (
	PROVCLAIMNO VARCHAR2 (40) NOT NULL,
	ENCOUNTERID VARCHAR2 (20) NOT NULL,
	ENCOUNTERSTARTDATE DATE NOT NULL,
	ENCOUNTERENDDATE DATE NOT NULL,
	ENCOUNTERCLASS VARCHAR2(20) NOT NULL,
	ENCOUNTERSERVICETYPE VARCHAR2(20),
	PRIORITY VARCHAR2(20),
	SERVICEPROVIDER VARCHAR2(20),
	ENCOUNTERSTATUS VARCHAR2(20) NOT NULL,
	CAUSEOFDEATH VARCHAR2(10),
    SERVICEEVENTTYPE VARCHAR2(10),
 Constraint PK_CLAIMENCOUNTERS primary key (PROVCLAIMNO,ENCOUNTERID)
);

Alter table NPHIES_CLAIMENCOUNTERS add Constraint FK_CLAIMENCOUNTERS foreign key (PROVCLAIMNO) references NPHIES_CLAIMINFO (PROVCLAIMNO);
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
