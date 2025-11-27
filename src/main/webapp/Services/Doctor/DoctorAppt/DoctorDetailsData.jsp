<jsp:include page="/auth/SessisonInit.jsp" />


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
request.setCharacterEncoding("UTF-8");

/* ==========================================================
   READ DOCTOR ID
========================================================== */
String doctorId = request.getParameter("id");
if (doctorId == null || doctorId.trim().isEmpty()) {
    out.println("<h2 class='text-red-600 text-xl'>Invalid doctor ID.</h2>");
    return;
}

/* USER SESSION */
Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) memberId = 1;

/* ==========================================================
   DB CONNECTION
========================================================== */
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
    "root",
    "1G9r5a6c1E**"
);

/* ==========================================================
   FETCH DOCTOR DATA
========================================================== */
PreparedStatement psDoc = conn.prepareStatement(
    "SELECT * FROM doctor WHERE id=?"
);
psDoc.setString(1, doctorId);
ResultSet doc = psDoc.executeQuery();

if (!doc.next()) {
    out.println("<h2 class='text-red-600 text-xl'>Doctor not found.</h2>");
    conn.close();
    return;
}

double basePrice = doc.getDouble("base_price");

/* ==========================================================
   FETCH PACKAGES
========================================================== */
PreparedStatement psPkg = conn.prepareStatement(
    "SELECT * FROM doctor_package WHERE doctor_id=? AND is_active=1"
);
psPkg.setString(1, doctorId);
ResultSet pkg = psPkg.executeQuery();

/* ==========================================================
   USER IS ALLOWED TO REVIEW?
========================================================== */
PreparedStatement psAllowed = conn.prepareStatement(
    "SELECT 1 FROM doctor_appointment WHERE member_id=? AND doctor_id=? AND status IN ('PENDING','COMPLETED')"
);
psAllowed.setInt(1, memberId);
psAllowed.setString(2, doctorId);
ResultSet allowReview = psAllowed.executeQuery();
boolean canReview = allowReview.next();

/* Check if user already reviewed this doctor */
PreparedStatement psMyReview = conn.prepareStatement(
    "SELECT * FROM doctor_review WHERE member_id=? AND doctor_id=?"
);
psMyReview.setInt(1, memberId);
psMyReview.setString(2, doctorId);
ResultSet myReview = psMyReview.executeQuery();
boolean hasMyReview = myReview.next();

/* ==========================================================
   FETCH ALL REVIEWS WITH REPLIES
========================================================== */
PreparedStatement psReviews = conn.prepareStatement(
    "SELECT * FROM doctor_review WHERE doctor_id=? ORDER BY created_at DESC"
);
psReviews.setString(1, doctorId);
ResultSet reviews = psReviews.executeQuery();

PreparedStatement psReplies = conn.prepareStatement(
    "SELECT * FROM doctor_review_reply WHERE review_id=? ORDER BY created_at ASC"
);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100 p-4">

<div class="max-w-4xl mx-auto space-y-8">

    <!-- ======================================================
         DOCTOR INFO
    ======================================================= -->
    <div class="bg-white p-6 rounded-xl shadow">
        <h2 class="text-2xl font-bold mb-4"><%= doc.getString("name") %></h2>

        <p><b>Specialty:</b> <%= doc.getString("specialty") %></p>
        <p><b>Experience:</b> <%= doc.getInt("experience_years") %> years</p>
        <p><b>About:</b> <%= doc.getString("about") %></p>

        <p class="mt-3"><b>Base Price:</b> $<%= String.format("%.2f", basePrice) %></p>
    </div>

    <!-- ======================================================
     PACKAGES
======================================================= -->
<div class="bg-white p-6 rounded-xl shadow">
    <h3 class="text-xl font-semibold mb-4">Available Packages</h3>

    <%
    while (pkg.next()) {
        int pkgId = pkg.getInt("id");
        String pName = pkg.getString("package_name");
        String pDesc = pkg.getString("description");
        String type  = pkg.getString("adjust_type");
        double val   = pkg.getDouble("adjust_value");

        // ============================
        // CORRECT DISCOUNT CALCULATION
        // =============================
        double finalPrice = basePrice;

			if ("FLAT".equalsIgnoreCase(type)) {
			    // positive = add, negative = subtract
			    finalPrice = basePrice + val;
			
			} else if ("PERCENT".equalsIgnoreCase(type)) {
			    // positive = add %, negative = subtract %
			    finalPrice = basePrice + (basePrice * (val / 100.0));
			}
			
			// Ensure no negative price
			if (finalPrice < 0) finalPrice = 0;

    %>

    <div class="bg-gray-50 p-4 rounded-lg border shadow-sm mb-4">
        <h4 class="font-semibold text-lg"><%= pName %></h4>
        <p class="text-sm text-gray-600 mb-2"><%= pDesc %></p>

       
       <p><b>Base Price:</b> $<%= String.format("%.2f", basePrice) %></p>

<%-- NEGATIVE = DISCOUNT --%>
<% if (val < 0) { %>
    <p><b>Discount:</b>
        <% if ("FLAT".equalsIgnoreCase(type)) { %>
            -$<%= String.format("%.2f", Math.abs(val)) %>
        <% } else { %>
            -<%= Math.abs(val) %>%
        <% } %>
    </p>

<%-- POSITIVE = ADJUSTMENT (SURCHARGE) --%>
<% } else if (val > 0) { %>
    <p><b>Adjustment:</b>
        <% if ("FLAT".equalsIgnoreCase(type)) { %>
            +$<%= String.format("%.2f", val) %>
        <% } else { %>
            +<%= val %>%
        <% } %>
    </p>
<% } %>

<p><b>Final Price:</b>
    <span style="color:green;">
        $<%= String.format("%.2f", finalPrice) %>
    </span>
</p>

        

       
        <button
            class="mt-3 px-4 py-2 bg-blue-600 text-white rounded-lg"
            onclick="
                parent.selectPackageFromIframe('<%= pkgId %>', '<%= pName %>');
                parent.updatePrice(<%= basePrice %>, '<%= type %>', <%= val %>);
            ">
            Select Package
        </button>
    </div>

    <% } %>
</div>


   
</div>
</body>
</html>

<%
conn.close();
%>
