CREATE DATABASE HOSPITAL;
GO
USE HOSPITAL;
GO
CREATE TABLE Department(
DepartmentNo int primary key not null,
Department varchar(20) not null
)
CREATE TABLE Doctor(
DoctorNo varchar(10) primary key not null,
DoctorFName varchar(20) not null,
DoctorLName varchar(20) not null
)
CREATE TABLE Surgeon(
SurgeonNo varchar(10) primary key not null,
SurgeonFName varchar(20) not null,
SurgeonLName varchar(20) not null
)
CREATE TABLE Patient(
NHI varchar(10) primary key,
PatFName varchar(20) not null,
PatLName varchar(20) not null,
DOB date not null,
Gender varchar(10) not null,
DoctorNo varchar(10) not null
foreign key (DoctorNo) references Doctor (DoctorNo)
)

CREATE TABLE Referral(
ReferralNo varchar(20) primary key not null,
HealthTarget varchar(5) not null,
RefFrom varchar(10) not null,
RefDate date not null,
DoctorNo varchar(10) not null,
PatNHI varchar(10) not null,
foreign key (PatNHI) references Patient (NHI),
foreign key (DoctorNo) references Doctor (DoctorNo)
)

CREATE TABLE Waitlist(
WaitlistNo int primary key not null,
FSA date not null,
DateAdded date not null,
ReferralNo varchar(20) not null,
SurgeonNo varchar(10) not null,
foreign key (ReferralNo) references Referral (ReferralNo),
foreign key (SurgeonNo) references Surgeon (SurgeonNo)
)
