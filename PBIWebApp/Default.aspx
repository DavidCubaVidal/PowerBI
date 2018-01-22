<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PBIWebApp._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript" src="scripts/powerbi.js"></script>
    <script src="scripts/jquery.min.js"></script>
    <link href="css/HomeStyle.css" rel="stylesheet" />
    <script src="scripts/configFile.js"></script>

    <script type="text/javascript">

        var ReportPageName = "ReportSection";
        var cargarReport = 0;
        var indexGlobal = 1;

        function CrearTabsReportes() {

            var numberReports = document.getElementById('MainContent_txtNumberReports').value;
            var Token = document.getElementById('MainContent_accessToken').value;

            for (i = 0; i < numberReports; i++) {

                var Token = document.getElementById('MainContent_accessToken').value;
                var Data = JSON.stringify({ index: i, accessToken: Token });

                $.when($.ajax({
                    url: '<%= ResolveUrl("Default.aspx/GetNewReport") %>',
                    data: Data,
                    type: "POST",
                    dataType: "json",
                    async: false,
                    cache: false,
                    contentType: "application/json; charset=utf-8",
                    success: function (mydata) {
                        console.log(mydata.d);

                        var embedUrl = mydata.d.embedUrl;
                        var reportId = mydata.d.id;
                        var name = mydata.d.name;
                    }
                })).done(function (data) {

                    var element = document.createElement("input");
                    element.type = "button";
                    element.value = data.d.name;
                    element.id = data.d.index;
                    element.setAttribute('onclick', 'CambiarReporte(' + data.d.index + ')');
                    $(".tab").append(element);
                });
            }
        }

        function CambiarReporte(index) {

            var NewIndexGlobar = indexGlobal - 1;
            var indexChange = NewIndexGlobar.toString();
            document.getElementById(indexChange).style.backgroundColor = "";

            cargarReport = 0;
            document.getElementById('MainContent_txtNumberIndexReportClick').value = index;

            indexGlobal = index + 1;
            var Token = document.getElementById('MainContent_accessToken').value;
            var Data = JSON.stringify({ index: index, accessToken: Token });

            $.ajax({
                url: '<%= ResolveUrl("Default.aspx/GetNewReport") %>',
                data: Data,
                type: "POST",
                dataType: "json",
                cache: false,
                contentType: "application/json; charset=utf-8",
                success: function (mydata) {
                    if (mydata.d.linkRedirect != null && mydata.d.linkRedirect != "") {
                        window.location.replace(mydata.d.linkRedirect);
                        return;
                    }

                    var embedUrl = mydata.d.embedUrl;
                    var reportId = mydata.d.id;
                    var pageName = null;

                    var config = {
                        type: 'report',
                        accessToken: Token,
                        embedUrl: embedUrl,
                        id: reportId,
                        newRender: true,
                        pageName: pageName == null ? 'ReportSection' : pageName,
                        settings: {
                            filterPaneEnabled: true,
                            navContentPaneEnabled: true
                        }
                    };

                    var reportContainer = document.getElementById('reportContainer');
                    var report = powerbi.embedNew(reportContainer, config);

                    report.on("pageChanged", function (event) {

                        var page = event.detail.newPage;
                        document.getElementById('MainContent_txtNumberPageReportIndex').value = page.name;
                        ReportPageName = page.name;

                        if (cargarReport == 1) {
                            var NewIndexGlobar = indexGlobal - 1;
                            var indexChange = NewIndexGlobar.toString();
                            document.getElementById(indexChange).style.backgroundColor = "#ccc";
                        }
                    });
                    cargarReport = 1;
                }
            });
        }

        function SetFull() {
            var reportContainer = document.getElementById('reportContainer');
            var reporte = powerbi.get(reportContainer);
            reporte.fullscreen();
        };

        function SetPage(pageName) {
            var reportContainer = document.getElementById('reportContainer');
            var reporte = powerbi.get(reportContainer);
            reporte.setPage(pageName)
                .then(function (result) {
                    console.log(result);
                })
                .catch(function (errors) {
                    console.log(errors);
                });
        }

        function GetPages() {
            var reportContainer = document.getElementById('reportContainer');
            var reporte = powerbi.get(reportContainer);
            reporte.getPages()
                .then(function (pages) {
                    pages.forEach(function (page) {
                        var log = page.name + " - " + page.displayName;
                        console.log(log);
                    });
                })
                .catch(function (error) {
                    console.log(error);
                });
        };

        window.onload = function () {
            this.render(null);

            window.setInterval(ValidarRefrescarReporte1, Default_Timer * 1000);
            window.setInterval(ValidarRefrescarReporte2, Default_Timer * 1000);
            window.setInterval(ValidarRefrescarReporte3, Default_Timer * 1000);
            window.setInterval(ValidarRefrescarReporte4, Default_Timer * 1000);
            window.setInterval(ValidarRefrescarReporteN, Default_Timer * 1000);
        };

        function ValidarRefrescarReporte1() {
            if (indexGlobal == 1 && cargarReport == 1) {
                RefrescarReporte();
                cargarReport = 0;
            }
        }

        function ValidarRefrescarReporte2() {
            if (indexGlobal == 2 && cargarReport == 1) {
                RefrescarReporte();
                cargarReport = 0;
            }
        }

        function ValidarRefrescarReporte3() {
            if (indexGlobal == 3 && cargarReport == 1) {
                RefrescarReporte();
                cargarReport = 0;
            }
        }

        function ValidarRefrescarReporte4() {
            if (indexGlobal == 4 && cargarReport == 1) {
                RefrescarReporte();
                cargarReport = 0;
            }
        }

        function ValidarRefrescarReporteN() {
            if (indexGlobal >= 5 && cargarReport == 1) {
                RefrescarReporte();
                cargarReport = 0;
            }
        }

        function RefrescarReporte() {

            cargarReport = 0;
            var Token = document.getElementById('MainContent_accessToken').value;
            var index = document.getElementById('MainContent_txtNumberIndexReportClick').value;
            var pageName = null;

            var pageNameCheck = document.getElementById('MainContent_txtNumberPageReportIndex').value;
            var Data = JSON.stringify({ index: index, accessToken: Token });

            $.ajax({
                url: '/Default.aspx/GetNewReport',
                data: Data,
                type: "POST",
                dataType: "json",
                cache: false,
                contentType: "application/json; charset=utf-8",
                success: function (mydata) {

                    var embedUrl = mydata.d.embedUrl;
                    var reportId = mydata.d.id;

                    var config = {
                        type: 'report',
                        accessToken: mydata.d.accessToken,
                        embedUrl: embedUrl,
                        id: reportId,
                        newRender: true,
                        pageName: pageNameCheck == null ? 'ReportSection' : pageNameCheck,
                        settings: {
                            filterPaneEnabled: true,
                            navContentPaneEnabled: true
                        }
                    };

                    var reportContainer = document.getElementById('reportContainer');
                    var report = powerbi.embedNew(reportContainer, config);

                    report.on("pageChanged", function (event) {
                        var page = event.detail.newPage;
                        ReportPageName = page.name;
                    });
                    cargarReport = 1;
                }
            });
        }

        function render(pageName) {

            var Token = document.getElementById('MainContent_accessToken');
            var accessToken = '';

            if (Token)
                accessToken = Token.value;

            if (!accessToken || accessToken == "") {
                return;
            }

            var embedUrl = document.getElementById('MainContent_txtEmbedUrl').value;
            var reportId = document.getElementById('MainContent_txtReportId').value;

            CrearTabsReportes();

            document.getElementById('MainContent_txtNumberIndexReportClick').value = 0;

            var config = {
                type: 'report',
                accessToken: accessToken,
                embedUrl: embedUrl,
                id: reportId,
                newRender: true,
                pageName: pageName == null ? 'ReportSection' : pageName,
                settings: {
                    filterPaneEnabled: true,
                    navContentPaneEnabled: true
                }
            };

            var reportContainer = document.getElementById('reportContainer');
            var report = powerbi.embed(reportContainer, config);

            document.getElementById('MainContent_txtNumberPageReportIndex').value = 'ReportSection';

            report.on("pageChanged", function (event) {
                var page = event.detail.newPage;
                ReportPageName = page.name;
                document.getElementById('MainContent_txtNumberPageReportIndex').value = page.name;
            });

            cargarReport = 1;

            var NewIndexGlobar = indexGlobal - 1;
            var indexChange = NewIndexGlobar.toString();
            document.getElementById(indexChange).style.backgroundColor = "#ccc";
        };
    </script>

    <asp:HiddenField ID="accessToken" runat="server" />

    <div style="display: none">
        <h3>Select <b>"Get Report"</b> to get and embed first report from your Power BI account.
        </h3>
        <asp:Button ID="getReportButton" runat="server" OnClick="getReportButton_Click" Text="Get Report" />

        <input type="button" value="Edit" id="editbutton" onclick="SetEdit()" />
    </div>

    <div class="tab">
    </div>

    <div class="field" style="display: none">
        <div class="fieldtxt">Report Name</div>
        <asp:TextBox ID="txtReportName" runat="server" Width="750px"></asp:TextBox>
    </div>

    <div class="field" style="display: none">
        <div class="fieldtxt">Report Id</div>
        <asp:TextBox ID="txtReportId" runat="server" Width="750px"></asp:TextBox>
    </div>

    <div class="field" style="display: none">
        <div class="fieldtxt">Report Embed URL</div>
        <asp:TextBox ID="txtEmbedUrl" runat="server" Width="750px"></asp:TextBox>
    </div>

    <div class="field" style="display: none">
        <div class="fieldtxt">Number Reports</div>
        <asp:TextBox ID="txtNumberReports" runat="server" Width="750px"></asp:TextBox>
    </div>

    <div class="field" style="display: none">
        <div class="fieldtxt">Number Index Report Click</div>
        <asp:TextBox ID="txtNumberIndexReportClick" runat="server" Width="750px"></asp:TextBox>
    </div>

    <div class="field" style="display: none">
        <div class="fieldtxt">Number Index Page Report Click</div>
        <asp:TextBox ID="txtNumberPageReportIndex" runat="server" Width="750px"></asp:TextBox>
    </div>

    <div id="reportContainer" style="position: fixed; top: 60px; left: 0px; bottom: 0px; right: 0px;">
    </div>

</asp:Content>
