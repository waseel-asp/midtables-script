
ALTER TABLE [nphies_beneficiary] 
ADD 
    [OCCUPATION] Varchar(20) NULL,
    [RELIGION] Varchar(5) NULL
go

ALTER TABLE [nphies_claimdiagnosis]
ADD
    [CONDITIONONSET] Varchar(10) NULL
go

ALTER TABLE [nphies_claimitem]
ADD
    [ISMATERNITY] Varchar(10) NULL
go

Create table [nphies_coverage_class] (
	[COVERAGECLASSID] Varchar(20) NOT NULL,
	[TYPE] Varchar(50) NOT NULL,
	[VALUE] Varchar(250) NOT NULL,
	[NAME] Varchar(250),
	[COVERAGEID] Varchar(20) NOT NULL,
 Constraint [PK_NPHIES_COVERAGE_CLASS] primary key ([COVERAGECLASSID])
)
go

Alter table [nphies_coverage_class] add Constraint [FK_NPHIES_COVERAGE_CLASS] foreign key ([COVERAGEID]) references [nphies_coverage] ([COVERAGEID])
go


Alter table [nphies_claimencounters] DROP COLUMN [HOSPITALADMISSIONSPECIALITY]
go

Alter table [nphies_claimencounters] DROP COLUMN [HOSPITALDISCHARGESPECIALITY]
go

Alter table [nphies_claimencounters] DROP COLUMN [HOSPITALINTENDEDLENGTHOFSTAY]
go

Alter table [nphies_claimencounters] DROP COLUMN [HOSPITALIZATIONORIGIN]
go

Alter table [nphies_claimencounters] DROP COLUMN [HOSPITALADMISSIONSOURCE]
go

Alter table [nphies_claimencounters] DROP COLUMN [HOSPITALREADMISSION]
go

Alter table [nphies_claimencounters] DROP COLUMN [HOSPITALDISCHARGEDISPOSITION]
go

ALTER TABLE [nphies_claimencounters]
ADD
    [CAUSEOFDEATH] Varchar(10) NULL,
    [SERVICEEVENTTYPE] Varchar(10) NULL
go

Alter table [nphies_claimencounters] add Constraint [UNIQUE_ENCOUNTERS_ENCOUNTERID] UNIQUE ([ENCOUNTERID])
go

Create table [nphiesencounterhospitalization] (
	[ENCOUNTERHOSPITALIZATIONID]  Varchar (20) NOT NULL,
	[HOSPITALADMISSIONSPECIALITY]  Varchar (20) NOT NULL,
    [HOSPITALDISCHARGESPECIALITY]  Varchar (20) NULL,
    [HOSPITALINTENDEDLENGTHOFSTAY]  Varchar (20) NOT NULL,
    [HOSPITALIZATIONORIGIN]  Varchar (20) NULL,
    [HOSPITALADMISSIONSOURCE]  Varchar (20) NOT NULL,
    [HOSPITALREADMISSION]  Varchar (20) NULL,
    [HOSPITALDISCHARGEDISPOSITION]  Varchar (20) NULL,
	[ENCOUNTERID]  Varchar (20) NOT NULL,
 Constraint [PK_ENCOUNTERHOSPITALIZATION] primary key ([ENCOUNTERHOSPITALIZATIONID])
)
go

Alter table [nphiesencounterhospitalization] add Constraint [FK_ENCOUNTERHOSPITALIZATION] foreign key ([ENCOUNTERID]) references [nphies_claimencounters] ([ENCOUNTERID])
go

Create table [nphies_encounteremergency (
	[ENCOUNTEREMERGENCYID]  Varchar (20) NOT NULL,
	[EMERGENCYARRIVALCODE]  Varchar (20) NOT NULL,
	[EMERGENCYSERVICESTART] Datetime NOT NULL,
	[EMERGENCYDEPARTMENTDISPOSITION]  Varchar (20) NULL,
	[TRIAGECATEGORY]  Varchar (20) NOT NULL,
	[TRIAGEDATE] Datetime NOT NULL,
	[ENCOUNTERID]  Varchar (20) NOT NULL,
 Constraint [PK_ENCOUNTEREMERGENCY] primary key ([ENCOUNTEREMERGENCYID])
)
go

Alter table [nphies_encounteremergency] add Constraint [FK_ENCOUNTERMERGENCY] foreign key ([ENCOUNTERID]) references [nphies_claimencounters] ([ENCOUNTERID])
go

Alter table [nphies_claimsupportinginfo] alter column [category] Varchar (40) NOT NULL
go
