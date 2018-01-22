using System;
using System.Web;
using System.Web.UI;
using System.Collections.Specialized;
using Newtonsoft.Json;
using PBIWebApp.Properties;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System.Configuration;
using System.Diagnostics;
using System.Web.Services;

namespace PBIWebApp
{
    public partial class _Default : Page
    {
        string baseUri = Properties.Settings.Default.PowerBiDataset;
        static string authorizedCode = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Params.Get("code") != null)
            {
                Session["AccessToken"] = GetAccessToken(
                    Request.Params.GetValues("code")[0],
                    Settings.Default.ClientID,
                    Settings.Default.ClientSecret,
                    Settings.Default.RedirectUrl);

                authorizedCode = Request.Params.GetValues("code")[0];

                Response.Redirect("/Default.aspx");
            }

            if (Session["AccessToken"] != null)
            {
                accessToken.Value = Session["AccessToken"].ToString();
                GetReport(0);
            }
            else
            {
                getReportButton_Click(sender, e);
            }


        }

        protected void getReportButton_Click(object sender, EventArgs e)
        {
            GetAuthorizationCode();
        }

        protected void GetReport(int index)
        {
            System.Net.WebRequest request = System.Net.WebRequest.Create(
                String.Format("{0}/Reports",
                baseUri)) as System.Net.HttpWebRequest;

            request.Method = "GET";
            request.ContentLength = 0;
            //request.CachePolicy = false;

            request.Headers.Add("Authorization", String.Format("Bearer {0}", accessToken.Value));
            PBIReports Reports;

            using (var response = request.GetResponse() as System.Net.HttpWebResponse)
            {

                using (var reader = new System.IO.StreamReader(response.GetResponseStream()))
                {

                    Reports = JsonConvert.DeserializeObject<PBIReports>(reader.ReadToEnd());
                }
            }

            if (Reports.value.Length > 0)
            {
                var report = Reports.value[index];

                txtEmbedUrl.Text = report.embedUrl;
                txtReportId.Text = report.id;
                txtReportName.Text = report.name;
                txtNumberReports.Text = Reports.value.Length.ToString();
            }
        }

        [WebMethod]
        public static PBIReport GetNewReport(int index, string accessToken)
        {

            try
            {

                PBIReport oPBIReport = new PBIReport();
                string baseUri = Properties.Settings.Default.PowerBiDataset;


                System.Net.WebRequest request = System.Net.WebRequest.Create(
                    String.Format("{0}/Reports",
                    baseUri)) as System.Net.HttpWebRequest;

                try
                {
                    accessToken = GetAccessTokenStatic(
                authorizedCode,
                Settings.Default.ClientID,
                Settings.Default.ClientSecret,
                Settings.Default.RedirectUrl);
                }
                catch (Exception)
                {
                    accessToken = HttpContext.Current.Session["AccessToken"].ToString();
                }

                request.Method = "GET";
                request.ContentLength = 0;
                request.Headers.Add("Authorization", String.Format("Bearer {0}", accessToken));
                PBIReports Reports;

                using (var response = request.GetResponse() as System.Net.HttpWebResponse)
                {

                    using (var reader = new System.IO.StreamReader(response.GetResponseStream()))
                    {

                        Reports = JsonConvert.DeserializeObject<PBIReports>(reader.ReadToEnd());
                    }
                }

                if (Reports.value.Length > 0)
                {
                    var report = Reports.value[index];

                    oPBIReport.embedUrl = report.embedUrl;
                    oPBIReport.id = report.id;
                    oPBIReport.name = report.name;
                    oPBIReport.index = index;
                    oPBIReport.accessToken = accessToken;
                }

                return oPBIReport;
            }
            catch (Exception ex)
            {
                //Token NULL
                HttpContext.Current.Session["AccessToken"] = null;

                var @params = new NameValueCollection
                {
                    {"response_type", "code"},
                    {"client_id", Settings.Default.ClientID},
                    {"resource", Properties.Settings.Default.PowerBiAPI},
                    { "redirect_uri", Settings.Default.RedirectUrl}
                };

                var queryString = HttpUtility.ParseQueryString(string.Empty);
                queryString.Add(@params);

                PBIReport oPBIReport = new PBIReport();
                oPBIReport.linkRedirect = String.Format(Properties.Settings.Default.AADAuthorityUri + "?{0}", queryString);
                return oPBIReport;
            }
        }

        public void GetAuthorizationCode()
        {

            var @params = new NameValueCollection
            {
                {"response_type", "code"},
                {"client_id", Settings.Default.ClientID},
                {"resource", Properties.Settings.Default.PowerBiAPI},
                { "redirect_uri", Settings.Default.RedirectUrl}
            };

            var queryString = HttpUtility.ParseQueryString(string.Empty);
            queryString.Add(@params);
            Response.Redirect(String.Format(Properties.Settings.Default.AADAuthorityUri + "?{0}", queryString));
        }

        public string GetAccessToken(string authorizationCode, string clientID, string clientSecret, string redirectUri)
        {
            TokenCache TC = new TokenCache();
            string authority = Properties.Settings.Default.AADAuthorityUri;
            AuthenticationContext AC = new AuthenticationContext(authority, TC);
            ClientCredential cc = new ClientCredential(clientID, clientSecret);

            return AC.AcquireTokenByAuthorizationCode(
                authorizationCode,
                new Uri(redirectUri), cc).AccessToken;
        }


        public static string GetAccessTokenStatic(string authorizationCode, string clientID, string clientSecret, string redirectUri)
        {
            TokenCache TC = new TokenCache();

            string authority = Properties.Settings.Default.AADAuthorityUri;
            AuthenticationContext AC = new AuthenticationContext(authority, TC);
            ClientCredential cc = new ClientCredential(clientID, clientSecret);

            return AC.AcquireTokenByAuthorizationCode(
                authorizationCode,
                new Uri(redirectUri), cc).AccessToken;
        }
    }

    public class PBIReports
    {
        public PBIReport[] value { get; set; }
    }
    public class PBIReport
    {
        public string id { get; set; }
        public string name { get; set; }
        public string webUrl { get; set; }
        public string embedUrl { get; set; }
        public int index { get; set; }
        public string accessToken { get; set; }
        public string linkRedirect { get; set; }
    }
}