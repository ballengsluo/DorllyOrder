﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Data.SqlClient;
using System.Xml;
using System.Collections;
using System.Net.Json;

/// <summary>
/// ImportService 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消注释以下行。 
// [System.Web.Script.Services.ScriptService]
public class Service : System.Web.Services.WebService {

    Data obj = new Data();
    public Service()
    {

        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 
    }

    [WebMethod]
    public int ExecuteNonQuery(string cmdText)
    {
        return obj.ExecuteNonQuery(cmdText);
    }

    [WebMethod]
    public DataSet PopulateDataSet(string cmdText)
    {
        return obj.PopulateDataSet(cmdText);
    }

    [WebMethod]
    public DateTime GetServerDateTime()
    {
        return GetDate();
    }


    //艾众管家
    [WebMethod]
    public string GenOrderFromParkinLot(string PRTableName,string MCTableName,string Guid,string Date)
    {
        string InfoMsg = "";
        SqlConnection con = null;
        SqlCommand command = null;
        try
        {
            con = Data.Conn();
            command = new SqlCommand("GenOrderFromParkinLot", con);
            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("@PRTableName", SqlDbType.NVarChar, 36).Value = PRTableName;
            command.Parameters.Add("@MCTableName", SqlDbType.NVarChar, 30).Value = MCTableName;
            command.Parameters.Add("@Guid", SqlDbType.NVarChar, 50).Value = Guid;
            command.Parameters.Add("@Date", SqlDbType.NVarChar, 30).Value = Date;
            command.Parameters.Add("@InfoMsg", SqlDbType.NVarChar, 500).Direction = ParameterDirection.Output;
            con.Open();
            command.ExecuteNonQuery();
            InfoMsg = command.Parameters["@InfoMsg"].Value.ToString();
        }
        catch (Exception ex)
        {
            InfoMsg = ex.ToString();
        }
        finally
        {
            if (command != null)
                command.Dispose();
            if (con != null)
                con.Dispose();
        }
        return InfoMsg;
    }

    [WebMethod]
    public string GenOrderFromConferenceRepair(string ResourceNo, string ResourceName, decimal amount, string Remark,string KEY)
    {
        if (KEY != "6E5F0C851FD4") return "";

        string InfoMsg = "";
        try
        {
            string prefix = GetDate().ToString("yyyyMM");
            string OrderNo = "";
            DataTable dt = obj.PopulateDataSet("select top 1 OrderNo from Op_OrderHeader where OrderNo like '" + prefix + "%' order by OrderNo desc").Tables[0];
            if (dt.Rows.Count > 0)
            {
                try
                {
                    long num = long.Parse(dt.Rows[0]["OrderNo"].ToString());
                    OrderNo = (num + 1).ToString();
                }
                catch
                {
                    OrderNo = prefix + "00001";
                }
            }
            else
            {
                OrderNo = prefix + "00001";
            }
            DateTime now = GetDate();
            string id = System.Guid.NewGuid().ToString();
            project.Business.Op.BusinessOrderHeader bc = new project.Business.Op.BusinessOrderHeader();
            bc.Entity.RowPointer = id;
            bc.Entity.OrderNo = OrderNo;
            bc.Entity.OrderType = "10";
            bc.Entity.CustNo = "22222";
            bc.Entity.OrderTime = now.AddDays(-now.Day + 1);
            bc.Entity.DaysofMonth = ParseDateForString(now.AddMonths(1).ToString("yyyy-MM") + "-01").AddDays(-1).Day;
            bc.Entity.ARDate = now;
            bc.Entity.ARAmount = amount;
            bc.Entity.ReduceAmount = 0;
            bc.Entity.PaidinAmount = 0;
            bc.Entity.Remark = Remark;

            bc.Entity.OrderCreator = "艾众管家";
            bc.Entity.OrderCreateDate = now;
            bc.Entity.OrderLastReviser = "艾众管家";
            bc.Entity.OrderLastRevisedDate = now;
            bc.Entity.OrderStatus = "0";
            bc.Save("insert");

            project.Business.Base.BusinessService bs = new project.Business.Base.BusinessService();
            bs.load("HYSZJ-59");

            project.Business.Op.BusinessOrderDetail detail = new project.Business.Op.BusinessOrderDetail();
            detail.Entity.RefRP = id;
            detail.Entity.ODSRVTypeNo1 = bs.Entity.SRVTypeNo1;
            detail.Entity.ODSRVTypeNo2 = bs.Entity.SRVTypeNo2;
            detail.Entity.ODSRVNo = bs.Entity.SRVNo;
            detail.Entity.ODContractSPNo = bs.Entity.SRVSPNo;
            detail.Entity.ResourceNo = ResourceNo;
            detail.Entity.ResourceName = ResourceName;
            detail.Entity.ODFeeStartDate = now;
            detail.Entity.ODFeeEndDate = now;
            detail.Entity.BillingDays = 1;
            detail.Entity.ODQTY = 1;
            detail.Entity.ODUnit = "";
            detail.Entity.ODUnitPrice = amount;
            detail.Entity.ODARAmount = amount;
            detail.Entity.ODCANo = bs.Entity.CANo;
            detail.Entity.ODCreator = "艾众管家";
            detail.Entity.ODCreateDate = now;
            detail.Entity.ODLastReviser = "艾众管家";
            detail.Entity.ODLastRevisedDate = now;
            detail.Entity.ODTaxRate = bs.Entity.SRVTaxRate;
            detail.Entity.ODTaxAmount = amount - Math.Round(amount / (1 + bs.Entity.SRVTaxRate), 2);
            detail.Save();

        }
        catch(Exception ex) 
        {
            InfoMsg = ex.Message;
        }

        return InfoMsg;
    }

    [WebMethod]
    public string GenOrderFromCompRepair(string CustNo, decimal amount, string Remark, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return "";

        string InfoMsg = "";
        try
        {
            string prefix = GetDate().ToString("yyyyMM");
            string OrderNo = "";
            DataTable dt = obj.PopulateDataSet("select top 1 OrderNo from Op_OrderHeader where OrderNo like '" + prefix + "%' order by OrderNo desc").Tables[0];
            if (dt.Rows.Count > 0)
            {
                try
                {
                    long num = long.Parse(dt.Rows[0]["OrderNo"].ToString());
                    OrderNo = (num + 1).ToString();
                }
                catch
                {
                    OrderNo = prefix + "00001";
                }
            }
            else
            {
                OrderNo = prefix + "00001";
            }
            DateTime now = GetDate();
            string id = System.Guid.NewGuid().ToString();
            project.Business.Op.BusinessOrderHeader bc = new project.Business.Op.BusinessOrderHeader();
            bc.Entity.RowPointer = id;
            bc.Entity.OrderNo = OrderNo;
            bc.Entity.OrderType = "11";
            bc.Entity.CustNo = CustNo;
            bc.Entity.OrderTime = now.AddDays(-now.Day + 1);
            bc.Entity.DaysofMonth = ParseDateForString(now.AddMonths(1).ToString("yyyy-MM") + "-01").AddDays(-1).Day;
            bc.Entity.ARDate = now;
            bc.Entity.ARAmount = amount;
            bc.Entity.ReduceAmount = 0;
            bc.Entity.PaidinAmount = 0;
            bc.Entity.Remark = Remark;

            bc.Entity.OrderCreator = "艾众管家";
            bc.Entity.OrderCreateDate = now;
            bc.Entity.OrderLastReviser = "艾众管家";
            bc.Entity.OrderLastRevisedDate = now;
            bc.Entity.OrderStatus = "0";
            bc.Save("insert");

            project.Business.Base.BusinessService bs = new project.Business.Base.BusinessService();
            bs.load("WXF-60");

            project.Business.Op.BusinessOrderDetail detail = new project.Business.Op.BusinessOrderDetail();
            detail.Entity.RefRP = id;
            detail.Entity.ODSRVTypeNo1 = bs.Entity.SRVTypeNo1;
            detail.Entity.ODSRVTypeNo2 = bs.Entity.SRVTypeNo2;
            detail.Entity.ODSRVNo = bs.Entity.SRVNo;
            detail.Entity.ODContractSPNo = bs.Entity.SRVSPNo;
            detail.Entity.ResourceNo = "";
            detail.Entity.ResourceName = "";
            detail.Entity.ODFeeStartDate = now;
            detail.Entity.ODFeeEndDate = now;
            detail.Entity.BillingDays = 1;
            detail.Entity.ODQTY = 1;
            detail.Entity.ODUnit = "";
            detail.Entity.ODUnitPrice = amount;
            detail.Entity.ODARAmount = amount;
            detail.Entity.ODCANo = bs.Entity.CANo;
            detail.Entity.ODCreator = "艾众管家";
            detail.Entity.ODCreateDate = now;
            detail.Entity.ODLastReviser = "艾众管家";
            detail.Entity.ODLastRevisedDate = now;
            detail.Entity.ODTaxRate = bs.Entity.SRVTaxRate;
            detail.Entity.ODTaxAmount = amount - Math.Round(amount / (1 + bs.Entity.SRVTaxRate), 2);
            detail.Save();

        }
        catch (Exception ex)
        {
            InfoMsg = ex.Message;
        }

        return InfoMsg;
    }

    [WebMethod]
    public string GenOrderFromCompRepairForWO(string CustNo, decimal amount, string Remark, string KEY, out string OrderNo)
    {
        OrderNo = "";
        if (KEY != "6E5F0C851FD4") return "";

        string InfoMsg = "";
        try
        {
            string prefix = GetDate().ToString("yyyyMM");
            DataTable dt = obj.PopulateDataSet("select top 1 OrderNo from Op_OrderHeader where OrderNo like '" + prefix + "%' order by OrderNo desc").Tables[0];
            if (dt.Rows.Count > 0)
            {
                try
                {
                    long num = long.Parse(dt.Rows[0]["OrderNo"].ToString());
                    OrderNo = (num + 1).ToString();
                }
                catch
                {
                    OrderNo = prefix + "00001";
                }
            }
            else
            {
                OrderNo = prefix + "00001";
            }
            DateTime now = GetDate();
            string id = System.Guid.NewGuid().ToString();
            project.Business.Op.BusinessOrderHeader bc = new project.Business.Op.BusinessOrderHeader();
            bc.Entity.RowPointer = id;
            bc.Entity.OrderNo = OrderNo;
            bc.Entity.OrderType = "11";
            bc.Entity.CustNo = CustNo;
            bc.Entity.OrderTime = now.AddDays(-now.Day + 1);
            bc.Entity.DaysofMonth = ParseDateForString(now.AddMonths(1).ToString("yyyy-MM") + "-01").AddDays(-1).Day;
            bc.Entity.ARDate = now;
            bc.Entity.ARAmount = amount;
            bc.Entity.ReduceAmount = 0;
            bc.Entity.PaidinAmount = 0;
            bc.Entity.Remark = Remark;

            bc.Entity.OrderCreator = "工单系统";
            bc.Entity.OrderCreateDate = now;
            bc.Entity.OrderLastReviser = "工单系统";
            bc.Entity.OrderLastRevisedDate = now;
            bc.Entity.OrderStatus = "0";
            bc.Save("insert");

            project.Business.Base.BusinessService bs = new project.Business.Base.BusinessService();
            bs.load("WXF-60");

            project.Business.Op.BusinessOrderDetail detail = new project.Business.Op.BusinessOrderDetail();
            detail.Entity.RefRP = id;
            detail.Entity.ODSRVTypeNo1 = bs.Entity.SRVTypeNo1;
            detail.Entity.ODSRVTypeNo2 = bs.Entity.SRVTypeNo2;
            detail.Entity.ODSRVNo = bs.Entity.SRVNo;
            detail.Entity.ODContractSPNo = bs.Entity.SRVSPNo;
            detail.Entity.ResourceNo = "";
            detail.Entity.ResourceName = "";
            detail.Entity.ODFeeStartDate = now;
            detail.Entity.ODFeeEndDate = now;
            detail.Entity.BillingDays = 1;
            detail.Entity.ODQTY = 1;
            detail.Entity.ODUnit = "";
            detail.Entity.ODUnitPrice = amount;
            detail.Entity.ODARAmount = amount;
            detail.Entity.ODCANo = bs.Entity.CANo;
            detail.Entity.ODCreator = "工单系统";
            detail.Entity.ODCreateDate = now;
            detail.Entity.ODLastReviser = "工单系统";
            detail.Entity.ODLastRevisedDate = now;
            detail.Entity.ODTaxRate = bs.Entity.SRVTaxRate;
            detail.Entity.ODTaxAmount = amount - Math.Round(amount / (1 + bs.Entity.SRVTaxRate), 2);
            detail.Save();
        }
        catch (Exception ex)
        {
            InfoMsg = ex.Message;
        }

        return InfoMsg;
    }


    //工单
    [WebMethod]
    public string GetMeterInfo(string MeterNo, string KEY, out string meterRMID, out decimal readout,out int digit)
    {
        meterRMID = "";
        readout = 0;
        digit = 0;
        string InfoMsg = "";
        if (KEY != "6E5F0C851FD4")
        {
            InfoMsg = "参数有误！";
            return "";
        }
        try
        {
            DataTable dt = obj.PopulateDataSet("select MeterReadout,MeterRate,MeterDigit,MeterRMID from Mstr_Meter where MeterNo='" + MeterNo + "'").Tables[0];
            if (dt.Rows.Count > 0)
            {
                meterRMID = dt.Rows[0]["MeterRMID"].ToString();
                readout = ParseDecimalForString(dt.Rows[0]["MeterReadout"].ToString());
                digit = ParseIntForString(dt.Rows[0]["MeterDigit"].ToString());
            }
            else
            {
                InfoMsg = "当前表记编号不存在！";
            }
        }
        catch { InfoMsg = "获取表记信息"; }
        return InfoMsg;
    }

    [WebMethod]
    public string MeterReadout(string MeterNo, string ReadoutType, decimal LastReadout, decimal Readout, decimal JoinReadings, decimal Readings, string UserName, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return "";

        string InfoMsg = "";
        try
        {
            project.Business.Op.BusinessReadout bc = new project.Business.Op.BusinessReadout();
            string id = Guid.NewGuid().ToString();
            bc.Entity.RowPointer = id;
            bc.Entity.MeterNo = MeterNo;

            string isOk = "1";
            try
            {
                project.Business.Base.BusinessMeter bm = new project.Business.Base.BusinessMeter();
                bm.load(MeterNo);
                bc.Entity.RMID = bm.Entity.MeterRMID;
                bc.Entity.MeterType = bm.Entity.MeterType;
                bc.Entity.MeteRate = bm.Entity.MeterRate;
            }
            catch
            {
                isOk = "0";
                InfoMsg = "当前表记未找到！";
            }

            if (isOk == "1")
            {
                bc.Entity.ReadoutType = ReadoutType;
                bc.Entity.LastReadout = LastReadout;
                bc.Entity.Readout = Readout;
                bc.Entity.JoinReadings = JoinReadings;
                bc.Entity.Readings = Readings;
                bc.Entity.ROOperator = UserName;
                bc.Entity.RODate = GetDate();

                bc.Entity.ROCreateDate = GetDate();
                bc.Entity.ROCreator = UserName;

                //获取换表记录 [换表记录已审核，并没有被抄表引用]
                DataTable dt = obj.PopulateDataSet("select RowPointer,OldMeterReadings from Op_ChangeMeter " +
                    "where AuditStatus='1' and NewMeterNo='" + bc.Entity.MeterNo + "' " +
                    "and RowPointer not in (select ChangeID from Op_Readout_ChangeList)").Tables[0];
                if (dt.Rows.Count > 0)
                {
                    bc.Entity.IsChange = true;
                    decimal OldMeterReadings = 0;

                    //考虑多次换表的情况
                    foreach (DataRow dr in dt.Rows)
                    {
                        OldMeterReadings += ParseDecimalForString(dr["OldMeterReadings"].ToString());
                    }
                    bc.Entity.OldMeterReadings = OldMeterReadings;
                }
                else
                {
                    bc.Entity.IsChange = false;
                    bc.Entity.OldMeterReadings = 0;
                }

                int r = bc.Save("insert");
                if (r <= 0)
                {
                    InfoMsg = "抄表写入失败！";
                }
                else
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        obj.ExecuteNonQuery("insert into Op_Readout_ChangeList(RowPointer,RefRP,ChangeID) values(newid(),'" + id + "','" + dr["RowPointer"].ToString() + "')");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            InfoMsg = ex.Message;
        }

        return InfoMsg;
    }

    //资源
    [WebMethod]
    public DataTable GetStatisticsList_Resourse(string ResType, string StartDate, string EndDate, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return null;

        SqlConnection con = null;
        SqlCommand command = null;
        DataSet ds = new DataSet();
        try
        {
            con = Data.Conn();
            command = new SqlCommand("GetStatisticsList_Resourse", con);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@ResType", SqlDbType.NVarChar, 10).Value = ResType;
            command.Parameters.Add("@StartDate", SqlDbType.NVarChar, 10).Value = StartDate;
            command.Parameters.Add("@EndDate", SqlDbType.NVarChar, 10).Value = EndDate;
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.Fill(ds);
            return ds.Tables[0];
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(ex.Message);
            return null;
        }
        finally
        {
            if (command != null)
                command.Dispose();
            if (con != null)
                con.Dispose();
        }
    }

    [WebMethod]
    public DataSet GetStatisticsList_Room(string StartDate, string EndDate, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return null;

        SqlConnection con = null;
        SqlCommand command = null;
        DataSet ds = new DataSet();
        try
        {
            con = Data.Conn();
            command = new SqlCommand("GetStatisticsList_Room", con);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@StartDate", SqlDbType.NVarChar, 10).Value = StartDate;
            command.Parameters.Add("@EndDate", SqlDbType.NVarChar, 10).Value = EndDate;
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.Fill(ds);
            return ds;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(ex.Message);
            return null;
        }
        finally
        {
            if (command != null)
                command.Dispose();
            if (con != null)
                con.Dispose();
        }
    }
    [WebMethod]
    public DataTable GetStatisticsList_Room_Charts(string StartDate, string EndDate, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return null;

        SqlConnection con = null;
        SqlCommand command = null;
        DataSet ds = new DataSet();
        try
        {
            con = Data.Conn();
            command = new SqlCommand("GetStatisticsList_Room_Charts", con);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@StartDate", SqlDbType.NVarChar, 10).Value = StartDate;
            command.Parameters.Add("@EndDate", SqlDbType.NVarChar, 10).Value = EndDate;
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.Fill(ds);
            return ds.Tables[0];
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(ex.Message);
            return null;
        }
        finally
        {
            if (command != null)
                command.Dispose();
            if (con != null)
                con.Dispose();
        }
    }
    [WebMethod]
    public DataTable GetOccupancyRate(string StartDate, string EndDate, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return null;

        SqlConnection con = null;
        SqlCommand command = null;
        DataSet ds = new DataSet();
        try
        {
            con = Data.Conn();
            command = new SqlCommand("GetOccupancyRate", con);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@MinMonth", SqlDbType.NVarChar, 7).Value = StartDate;
            command.Parameters.Add("@MaxMonth", SqlDbType.NVarChar, 7).Value = EndDate;
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.Fill(ds);
            return ds.Tables[0];
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(ex.Message);
            return null;
        }
        finally
        {
            if (command != null)
                command.Dispose();
            if (con != null)
                con.Dispose();
        }
    }
    [WebMethod]
    public DataTable GetStatisticsList_WP_Charts(string StartDate, string EndDate, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return null;

        SqlConnection con = null;
        SqlCommand command = null;
        DataSet ds = new DataSet();
        try
        {
            con = Data.Conn();
            command = new SqlCommand("GetStatisticsList_WP_Charts", con);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@StartDate", SqlDbType.NVarChar, 10).Value = StartDate;
            command.Parameters.Add("@EndDate", SqlDbType.NVarChar, 10).Value = EndDate;
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.Fill(ds);
            return ds.Tables[0];
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(ex.Message);
            return null;
        }
        finally
        {
            if (command != null)
                command.Dispose();
            if (con != null)
                con.Dispose();
        }
    }
    [WebMethod]
    public DataTable GetStatisticsList_WP_Charts1(string MinMonth, string MaxMonth, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return null;

        SqlConnection con = null;
        SqlCommand command = null;
        DataSet ds = new DataSet();
        try
        {
            con = Data.Conn();
            command = new SqlCommand("GetStatisticsList_WP_Charts1", con);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@MinMonth", SqlDbType.NVarChar, 7).Value = MinMonth;
            command.Parameters.Add("@MaxMonth", SqlDbType.NVarChar, 7).Value = MaxMonth;
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.Fill(ds);
            return ds.Tables[0];
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(ex.Message);
            return null;
        }
        finally
        {
            if (command != null)
                command.Dispose();
            if (con != null)
                con.Dispose();
        }
    }
    [WebMethod]
    public DataTable GetStatisticsList_BB(string StartDate, string EndDate, string KEY)
    {
        if (KEY != "6E5F0C851FD4") return null;

        SqlConnection con = null;
        SqlCommand command = null;
        DataSet ds = new DataSet();
        try
        {
            con = Data.Conn();
            command = new SqlCommand("GetStatisticsList_BB", con);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@StartDate", SqlDbType.NVarChar, 10).Value = StartDate;
            command.Parameters.Add("@EndDate", SqlDbType.NVarChar, 10).Value = EndDate;
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.Fill(ds);
            return ds.Tables[0];
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(ex.Message);
            return null;
        }
        finally
        {
            if (command != null)
                command.Dispose();
            if (con != null)
                con.Dispose();
        }
    }

    private DateTime GetDate()
    {
        Data obj=new Data();
        return DateTime.Parse(obj.PopulateDataSet("select DT=getdate()").Tables[0].Rows[0]["DT"].ToString());
    }
    private System.DateTime ParseDateForString(string val)
    {
        if (string.IsNullOrEmpty(val))
        {
            return DateTime.MinValue.AddYears(1900);
        }

        return DateTime.Parse(val);
    }
    private decimal ParseDecimalForString(string val)
    {
        if (string.IsNullOrEmpty(val))
            return 0;

        return decimal.Parse(val);
    }
    private int ParseIntForString(string val)
        {
            if (string.IsNullOrEmpty(val))
                return 0;

            return Int32.Parse(val);
        }
}
