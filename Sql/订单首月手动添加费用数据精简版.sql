--����
insert into Op_ContractRMRentList(RowPointer,RefRP,RefNo,RMID,SRVNo,FeeStartDate,FeeEndDate,FeeQty,FeeUnitPrice,FeeAmount,FeeStatus,Creator,CreateDate,IsRefund)
select NEWID(),b.RowPointer,a.RowPointer,a.RMID,a.SRVNo,'2019-06-01','2019-06-30',0,a.UnitPrice,0,0,'�����',GETDATE(),0
from Op_ContractPropertyFee a 
left join Op_Contract b on a.RefRP=b.RowPointer
where
CONVERT(char(10),b.FeeStartDate,121)='2019-07-01' and
b.ContractNo='20190700054' and
b.ContractStatus='2' and 
b.ContractSPNo='FWC-004' and 
a.SRVNo in('DL-DF-1','DL-SF-1','DL-GTDF','DL-GTSF') and 
b.RowPointer not in (select RefRP from Op_ContractRMRentList where Creator='�����' group by RefRP)
--��ѯ
select b.RowPointer,b.ContractNo,b.ContractCreateDate,b.FeeStartDate,b.ContractCustNo,c.CustName,
a.RMID,a.UnitPrice,a.SRVNo
from Op_ContractPropertyFee a 
left join Op_Contract b on a.RefRP=b.RowPointer
left join Mstr_Customer c on b.ContractCustNo=c.CustNo
where
CONVERT(char(10),b.FeeStartDate,121)='2019-07-01' and
b.ContractNo='20190700054' and
b.ContractStatus='2' and 
b.ContractSPNo='FWC-004' and 
a.SRVNo in('DL-DF-1','DL-SF-1','DL-GTDF','DL-GTSF') and 
b.RowPointer not in (select RefRP from Op_ContractRMRentList where Creator='�����' group by RefRP)
order by b.FeeStartDate;
--�������������
select  b.ContractNo as '��ͬ���',c.CustName as '�ͻ�����'
from Op_ContractPropertyFee a 
left join Op_Contract b on a.RefRP=b.RowPointer
left join Mstr_Customer c on b.ContractCustNo=c.CustNo
where
CONVERT(char(10),b.FeeStartDate,121)='2019-03-01' and
b.ContractNo='20190600004' and
b.ContractStatus='2' and 
b.ContractSPNo='FWC-004' and 
a.SRVNo in('DL-DF-1','DL-SF-1','DL-GTDF','DL-GTSF') and 
b.RowPointer not in (select RefRP from Op_ContractRMRentList where Creator='�����' group by RefRP)
group by b.ContractNo,c.CustName order by b.ContractNo;

select  b.ContractNo as '��ͬ���',b.FeeStartDate as '�շѿ�ʼʱ��', c.CustName as '�ͻ�����'
from Op_ContractPropertyFee a 
left join Op_Contract b on a.RefRP=b.RowPointer
left join Mstr_Customer c on b.ContractCustNo=c.CustNo
where
b.ContractStatus='2' and 
CONVERT(char(10),b.FeeStartDate,121)='2019-03-01' and
b.ContractSPNo='FWC-004' and 
a.SRVNo in('DL-DF-1','DL-SF-1','DL-GTDF','DL-GTSF') and 
b.ContractNo='20190600004' and
b.RowPointer not in (select RefRP from Op_ContractRMRentList where Creator='�����' group by RefRP)
group by b.ContractNo,c.CustName,b.FeeStartDate order by b.FeeStartDate;
