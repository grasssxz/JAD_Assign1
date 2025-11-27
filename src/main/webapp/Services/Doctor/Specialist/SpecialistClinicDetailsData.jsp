<jsp:include page="/auth/SessisonInit.jsp" />

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
String id = request.getParameter("id");
if (id == null) { out.println("Invalid clinic ID"); return; }

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

PreparedStatement psClinic = conn.prepareStatement(
    "SELECT * FROM specialist_clinic WHERE id=?"
);
psClinic.setString(1, id);
ResultSet clinic = psClinic.executeQuery();
if (!clinic.next()) {
    out.println("Clinic not found");
    return;
}

PreparedStatement psPkg = conn.prepareStatement(
    "SELECT * FROM specialist_package WHERE clinic_id=? AND is_active=1"
);
psPkg.setString(1, id);
ResultSet pkgList = psPkg.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-white p-6">

<div class="space-y-10">

    <!-- ======================= CLINIC DETAILS ======================= -->
    <div class="bg-white p-6 rounded-xl shadow">
        <h2 class="text-2xl font-bold mb-2"><%= clinic.getString("name") %></h2>

        <p class="text-gray-700 mb-2"><%= clinic.getString("description") %></p>

        <p><b>Address:</b> <%= clinic.getString("address") %></p>
        <p><b>Phone:</b> <%= clinic.getString("phone") %></p>

        <p class="mt-3 font-semibold">
            <b>Base Price:</b>
            $<%= String.format("%.2f", clinic.getDouble("base_price")) %>
        </p>
    </div>


    <!-- ======================= AVAILABLE PACKAGES ======================= -->
<div class="bg-white p-6 rounded-xl shadow">
    <h3 class="text-xl font-semibold mb-4">Available Packages</h3>

    <%
    boolean hasPackages = false;

    while (pkgList.next()) {
        hasPackages = true;

        String pName        = pkgList.getString("name");
        String pDesc        = pkgList.getString("description");
        int duration        = pkgList.getInt("duration_minutes");
        double basePrice    = pkgList.getDouble("price");
        String adjustType   = pkgList.getString("adjust_type");
        double adjustValue  = pkgList.getDouble("adjust_value");

        // ============== CALCULATE FINAL PRICE (correct rules) ==============
        double finalPrice = basePrice;

        if ("FLAT".equalsIgnoreCase(adjustType)) {
            // positive = surcharge, negative = discount
            finalPrice = basePrice + adjustValue;

        } else if ("PERCENT".equalsIgnoreCase(adjustType)) {
            // positive = add %, negative = discount %
            finalPrice = basePrice + (basePrice * (adjustValue / 100.0));
        }

        if (finalPrice < 0) finalPrice = 0;
    %>

    <!-- ======================= PACKAGE CARD ======================= -->
    <div class="bg-gray-50 p-5 rounded-lg border shadow-sm mb-6">

        <h4 class="font-semibold text-lg"><%= pName %></h4>
        <p class="text-sm text-gray-600 mb-2"><%= pDesc %></p>

        <p><b>Duration:</b> <%= duration %> mins</p>

        <p class="mt-2 font-semibold">
            Base Price: $<%= String.format("%.2f", basePrice) %>
        </p>

        <!-- ===================== Discount or Adjustment ===================== -->
        <% if (adjustValue < 0) { %>
            <!-- DISCOUNT -->
            <p>
                <b>Discount:</b>
                <% if ("FLAT".equalsIgnoreCase(adjustType)) { %>
                    -$<%= String.format("%.2f", Math.abs(adjustValue)) %>
                <% } else { %>
                    -<%= Math.abs(adjustValue) %>%
                <% } %>
            </p>

        <% } else if (adjustValue > 0) { %>
            <!-- SURCHARGE / ADJUSTMENT -->
            <p>
                <b>Adjustment:</b>
                <% if ("FLAT".equalsIgnoreCase(adjustType)) { %>
                    +$<%= String.format("%.2f", adjustValue) %>
                <% } else { %>
                    +<%= adjustValue %>%
                <% } %>
            </p>
        <% } %>

        <!-- ======================= FINAL PRICE ======================= -->
        <p>
            <b>Final Price:</b>
            <span style="color:green;">$<%= String.format("%.2f", finalPrice) %></span>
        </p>

        <button
            class="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg"
            onclick="parent.selectPackageIframe(
                '<%= pkgList.getInt("id") %>',
                '<%= pName %>',
                <%= basePrice %>,
                <%= finalPrice %>,
                '<%= adjustType %>',
                <%= adjustValue %>
            )">
            Select Package
        </button>

    </div>

    <% } %>

    <% if (!hasPackages) { %>
    <p class="text-gray-600">No available packages.</p>
    <% } %>
</div>


</div>

</body>
</html>

<%
conn.close();
%>
