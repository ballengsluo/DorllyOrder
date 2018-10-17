﻿//------------------------------------------------------------------------------
// <auto-generated>
//     此代码由工具生成。
//     运行时版本:4.0.30319.42000
//
//     对此文件的更改可能会导致不正确的行为，并且如果
//     重新生成代码，这些更改将会丢失。
// </auto-generated>
//------------------------------------------------------------------------------

// 
// 此源代码是由 Microsoft.VSDesigner 4.0.30319.42000 版自动生成。
// 
#pragma warning disable 1591

namespace project.WOService {
    using System;
    using System.Web.Services;
    using System.Diagnostics;
    using System.Web.Services.Protocols;
    using System.Xml.Serialization;
    using System.ComponentModel;
    
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1099.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Web.Services.WebServiceBindingAttribute(Name="WebServiceSoap", Namespace="http://tempuri.org/")]
    public partial class WebService : System.Web.Services.Protocols.SoapHttpClientProtocol {
        
        private System.Threading.SendOrPostCallback GenOrderFormButlerOperationCompleted;
        
        private System.Threading.SendOrPostCallback SetCustomerOperationCompleted;
        
        private bool useDefaultCredentialsSetExplicitly;
        
        /// <remarks/>
        public WebService() {
            this.Url = global::project.Properties.Settings.Default.project_WOService_WebService;
            if ((this.IsLocalFileSystemWebService(this.Url) == true)) {
                this.UseDefaultCredentials = true;
                this.useDefaultCredentialsSetExplicitly = false;
            }
            else {
                this.useDefaultCredentialsSetExplicitly = true;
            }
        }
        
        public new string Url {
            get {
                return base.Url;
            }
            set {
                if ((((this.IsLocalFileSystemWebService(base.Url) == true) 
                            && (this.useDefaultCredentialsSetExplicitly == false)) 
                            && (this.IsLocalFileSystemWebService(value) == false))) {
                    base.UseDefaultCredentials = false;
                }
                base.Url = value;
            }
        }
        
        public new bool UseDefaultCredentials {
            get {
                return base.UseDefaultCredentials;
            }
            set {
                base.UseDefaultCredentials = value;
                this.useDefaultCredentialsSetExplicitly = true;
            }
        }
        
        /// <remarks/>
        public event GenOrderFormButlerCompletedEventHandler GenOrderFormButlerCompleted;
        
        /// <remarks/>
        public event SetCustomerCompletedEventHandler SetCustomerCompleted;
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://tempuri.org/GenOrderFormButler", RequestNamespace="http://tempuri.org/", ResponseNamespace="http://tempuri.org/", Use=System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
        public string GenOrderFormButler(string serviceNo, string srvName, string linkMan, string linkTel, string addr, string needTime, string custNo, string userName, string orderType, string KEY) {
            object[] results = this.Invoke("GenOrderFormButler", new object[] {
                        serviceNo,
                        srvName,
                        linkMan,
                        linkTel,
                        addr,
                        needTime,
                        custNo,
                        userName,
                        orderType,
                        KEY});
            return ((string)(results[0]));
        }
        
        /// <remarks/>
        public void GenOrderFormButlerAsync(string serviceNo, string srvName, string linkMan, string linkTel, string addr, string needTime, string custNo, string userName, string orderType, string KEY) {
            this.GenOrderFormButlerAsync(serviceNo, srvName, linkMan, linkTel, addr, needTime, custNo, userName, orderType, KEY, null);
        }
        
        /// <remarks/>
        public void GenOrderFormButlerAsync(string serviceNo, string srvName, string linkMan, string linkTel, string addr, string needTime, string custNo, string userName, string orderType, string KEY, object userState) {
            if ((this.GenOrderFormButlerOperationCompleted == null)) {
                this.GenOrderFormButlerOperationCompleted = new System.Threading.SendOrPostCallback(this.OnGenOrderFormButlerOperationCompleted);
            }
            this.InvokeAsync("GenOrderFormButler", new object[] {
                        serviceNo,
                        srvName,
                        linkMan,
                        linkTel,
                        addr,
                        needTime,
                        custNo,
                        userName,
                        orderType,
                        KEY}, this.GenOrderFormButlerOperationCompleted, userState);
        }
        
        private void OnGenOrderFormButlerOperationCompleted(object arg) {
            if ((this.GenOrderFormButlerCompleted != null)) {
                System.Web.Services.Protocols.InvokeCompletedEventArgs invokeArgs = ((System.Web.Services.Protocols.InvokeCompletedEventArgs)(arg));
                this.GenOrderFormButlerCompleted(this, new GenOrderFormButlerCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState));
            }
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://tempuri.org/SetCustomer", RequestNamespace="http://tempuri.org/", ResponseNamespace="http://tempuri.org/", Use=System.Web.Services.Description.SoapBindingUse.Literal, ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
        public string SetCustomer(
                    string CustNo, 
                    string CustName, 
                    string CustShortName, 
                    string CustType, 
                    string Representative, 
                    string BusinessScope, 
                    string CustLicenseNo, 
                    string RepIDCard, 
                    string CustContact, 
                    string CustTel, 
                    string CustContactMobile, 
                    string CustEmail, 
                    string CustBankTitle, 
                    string CustBankAccount, 
                    string CustBank, 
                    bool IsExternal, 
                    string UserName, 
                    string Type, 
                    string Key) {
            object[] results = this.Invoke("SetCustomer", new object[] {
                        CustNo,
                        CustName,
                        CustShortName,
                        CustType,
                        Representative,
                        BusinessScope,
                        CustLicenseNo,
                        RepIDCard,
                        CustContact,
                        CustTel,
                        CustContactMobile,
                        CustEmail,
                        CustBankTitle,
                        CustBankAccount,
                        CustBank,
                        IsExternal,
                        UserName,
                        Type,
                        Key});
            return ((string)(results[0]));
        }
        
        /// <remarks/>
        public void SetCustomerAsync(
                    string CustNo, 
                    string CustName, 
                    string CustShortName, 
                    string CustType, 
                    string Representative, 
                    string BusinessScope, 
                    string CustLicenseNo, 
                    string RepIDCard, 
                    string CustContact, 
                    string CustTel, 
                    string CustContactMobile, 
                    string CustEmail, 
                    string CustBankTitle, 
                    string CustBankAccount, 
                    string CustBank, 
                    bool IsExternal, 
                    string UserName, 
                    string Type, 
                    string Key) {
            this.SetCustomerAsync(CustNo, CustName, CustShortName, CustType, Representative, BusinessScope, CustLicenseNo, RepIDCard, CustContact, CustTel, CustContactMobile, CustEmail, CustBankTitle, CustBankAccount, CustBank, IsExternal, UserName, Type, Key, null);
        }
        
        /// <remarks/>
        public void SetCustomerAsync(
                    string CustNo, 
                    string CustName, 
                    string CustShortName, 
                    string CustType, 
                    string Representative, 
                    string BusinessScope, 
                    string CustLicenseNo, 
                    string RepIDCard, 
                    string CustContact, 
                    string CustTel, 
                    string CustContactMobile, 
                    string CustEmail, 
                    string CustBankTitle, 
                    string CustBankAccount, 
                    string CustBank, 
                    bool IsExternal, 
                    string UserName, 
                    string Type, 
                    string Key, 
                    object userState) {
            if ((this.SetCustomerOperationCompleted == null)) {
                this.SetCustomerOperationCompleted = new System.Threading.SendOrPostCallback(this.OnSetCustomerOperationCompleted);
            }
            this.InvokeAsync("SetCustomer", new object[] {
                        CustNo,
                        CustName,
                        CustShortName,
                        CustType,
                        Representative,
                        BusinessScope,
                        CustLicenseNo,
                        RepIDCard,
                        CustContact,
                        CustTel,
                        CustContactMobile,
                        CustEmail,
                        CustBankTitle,
                        CustBankAccount,
                        CustBank,
                        IsExternal,
                        UserName,
                        Type,
                        Key}, this.SetCustomerOperationCompleted, userState);
        }
        
        private void OnSetCustomerOperationCompleted(object arg) {
            if ((this.SetCustomerCompleted != null)) {
                System.Web.Services.Protocols.InvokeCompletedEventArgs invokeArgs = ((System.Web.Services.Protocols.InvokeCompletedEventArgs)(arg));
                this.SetCustomerCompleted(this, new SetCustomerCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState));
            }
        }
        
        /// <remarks/>
        public new void CancelAsync(object userState) {
            base.CancelAsync(userState);
        }
        
        private bool IsLocalFileSystemWebService(string url) {
            if (((url == null) 
                        || (url == string.Empty))) {
                return false;
            }
            System.Uri wsUri = new System.Uri(url);
            if (((wsUri.Port >= 1024) 
                        && (string.Compare(wsUri.Host, "localHost", System.StringComparison.OrdinalIgnoreCase) == 0))) {
                return true;
            }
            return false;
        }
    }
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1099.0")]
    public delegate void GenOrderFormButlerCompletedEventHandler(object sender, GenOrderFormButlerCompletedEventArgs e);
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1099.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    public partial class GenOrderFormButlerCompletedEventArgs : System.ComponentModel.AsyncCompletedEventArgs {
        
        private object[] results;
        
        internal GenOrderFormButlerCompletedEventArgs(object[] results, System.Exception exception, bool cancelled, object userState) : 
                base(exception, cancelled, userState) {
            this.results = results;
        }
        
        /// <remarks/>
        public string Result {
            get {
                this.RaiseExceptionIfNecessary();
                return ((string)(this.results[0]));
            }
        }
    }
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1099.0")]
    public delegate void SetCustomerCompletedEventHandler(object sender, SetCustomerCompletedEventArgs e);
    
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Web.Services", "4.6.1099.0")]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    public partial class SetCustomerCompletedEventArgs : System.ComponentModel.AsyncCompletedEventArgs {
        
        private object[] results;
        
        internal SetCustomerCompletedEventArgs(object[] results, System.Exception exception, bool cancelled, object userState) : 
                base(exception, cancelled, userState) {
            this.results = results;
        }
        
        /// <remarks/>
        public string Result {
            get {
                this.RaiseExceptionIfNecessary();
                return ((string)(this.results[0]));
            }
        }
    }
}

#pragma warning restore 1591