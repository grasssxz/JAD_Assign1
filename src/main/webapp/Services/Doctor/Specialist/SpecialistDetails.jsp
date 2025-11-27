<jsp:include page="/auth/SessisonInit.jsp" />
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Specialist Clinic Details</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<!-- =========================== NAV BAR =========================== -->
<jsp:include page="/home/NavBar.jsp" />

<%
String clinicId = request.getParameter("id");
if (clinicId == null) {
%>
    <div class="text-red-600 text-xl p-6">Invalid Clinic ID</div>
<%
    return;
}
%>

<div class="max-w-6xl mx-auto px-5 py-6">
    <h1 class="text-3xl font-bold text-gray-800 mb-6">Specialist Clinic Details</h1>

    <div class="space-y-8">

        <!-- ======================= IFRAME SECTION ======================= -->
        <iframe id="specialistFrame"
                class="w-full h-[700px] bg-white rounded-xl shadow border">
        </iframe>

        <!-- ======================= BOOKING SECTION ======================= -->

        <%
        // Auth-check only here (member needed for booking)
        %>
        <jsp:include page="/auth/AuthCheck.jsp" />
        <jsp:include page="/auth/RequireLogin.jsp" />

        <%
        String msg = request.getParameter("msg");
        if (msg != null && !msg.trim().equals("")) {
        %>
        <div class="bg-red-100 text-red-800 border border-red-300 px-4 py-3 rounded-lg shadow">
            <%= msg %>
        </div>
        <% } %>

        <div class="bg-white shadow p-6 rounded-xl">
            <h2 class="text-2xl font-semibold mb-4">Book Appointment</h2>

            <form action="SpecialistBooking.jsp" method="post" class="space-y-4">
                <input type="hidden" name="clinic_id" value="<%= clinicId %>">
                <input type="hidden" id="package_id" name="package_id">

                <div>
                    <label class="font-medium">Date</label>
                    <input type="date" name="appointment_date"
                           class="w-full border rounded-lg px-4 py-2" required>
                </div>

                <div>
                    <label class="font-medium">Time</label>
                    <input type="time" name="appointment_time"
                           class="w-full border rounded-lg px-4 py-2" required>
                </div>

                <!-- PRICE PREVIEW LIKE DOCTOR -->
                <div id="priceBox" class="hidden mt-3 p-4 bg-blue-50 rounded-lg border border-blue-300">
                    <p><b>Base Price:</b> $<span id="previewBase"></span></p>
                    <p><b>Adjustment:</b> <span id="previewAdj"></span></p>
                    <p><b>Final Price:</b> $<span id="previewFinal"></span></p>
                </div>

                <div>
                    <label class="font-medium">Selected Package</label>
                    <div id="packageDisplay"
                         class="w-full p-3 border rounded-lg bg-gray-100 text-gray-700">
                        No package selected.
                    </div>
                </div>

                <button class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-lg">
                    Confirm Appointment
                </button>
            </form>
        </div>

    </div>
</div>

<!-- ======================= REVIEWS SECTION ======================= -->

<div class="max-w-6xl mx-auto px-5 mt-14">
    <h2 class="text-3xl font-bold mb-6">Reviews</h2>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) memberId = -1;

// -------- DB CONNECTION ----------
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn2 = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

// -------- EDIT MODE DETECTION ----------
String editId = request.getParameter("edit"); // review ID being edited

// -------- CAN USER REVIEW? ----------
PreparedStatement allow2 = conn2.prepareStatement(
    "SELECT 1 FROM specialist_appointment WHERE member_id=? AND clinic_id=? " +
    "AND status IN ('pending','completed')"
);
allow2.setInt(1, memberId);
allow2.setString(2, clinicId);
boolean canReview2 = allow2.executeQuery().next();

PreparedStatement check2 = conn2.prepareStatement(
    "SELECT 1 FROM specialist_review WHERE member_id=? AND clinic_id=?"
);
check2.setInt(1, memberId);
check2.setString(2, clinicId);
boolean hasMyReview2 = check2.executeQuery().next();

// -------- LOAD REVIEWS ----------
PreparedStatement psReviews2 = conn2.prepareStatement(
    "SELECT r.*, m.username AS reviewer_name " +
    "FROM specialist_review r " +
    "JOIN member m ON r.member_id = m.id " +
    "WHERE r.clinic_id=? ORDER BY r.created_at DESC"
);
psReviews2.setString(1, clinicId);
ResultSet reviews2 = psReviews2.executeQuery();

PreparedStatement psReplies2 = conn2.prepareStatement(
    "SELECT * FROM specialist_review_reply WHERE review_id=? ORDER BY created_at ASC"
);
%>

<% if (canReview2 && !hasMyReview2) { %>
<form method="post"
      action="Reviews/SubmitSpecialistReview.jsp"
      class="mb-6 p-4 border rounded-lg bg-gray-50">
    <input type="hidden" name="clinic_id" value="<%= clinicId %>">

    <label class="font-medium">Rating</label>
    <select name="rating" class="border rounded-lg px-3 py-2 mb-3">
        <option value="5">⭐ 5</option>
        <option value="4">⭐ 4</option>
        <option value="3">⭐ 3</option>
        <option value="2">⭐ 2</option>
        <option value="1">⭐ 1</option>
    </select>

    <label class="font-medium">Review</label>
    <textarea name="review_text" rows="3"
              class="w-full border rounded-lg px-3 py-2 mb-3"></textarea>

    <button class="bg-blue-600 text-white px-4 py-2 rounded-lg">
        Submit Review
    </button>
</form>
<% } %>

<%
boolean anyReview2 = false;
while (reviews2.next()) {
    anyReview2 = true;
    int reviewId = reviews2.getInt("id");
    boolean isEditing = (editId != null && editId.equals(String.valueOf(reviewId)));
%>

<div class="mb-10 pb-6 border-b">

<% if (isEditing) { %>
    <!-- ======================= INLINE EDIT MODE ======================= -->

    <form method="post" action="Reviews/EditSpecialistReviewSubmit.jsp"
          class="p-4 bg-yellow-50 border rounded-lg space-y-3">

        <input type="hidden" name="id" value="<%= reviewId %>">
        <input type="hidden" name="clinic_id" value="<%= clinicId %>">

        <div>
            <label class="font-medium">Rating</label>
            <select name="rating" class="border rounded-lg px-3 py-2">
                <option value="5" <%= reviews2.getInt("rating")==5?"selected":"" %>>⭐ 5</option>
                <option value="4" <%= reviews2.getInt("rating")==4?"selected":"" %>>⭐ 4</option>
                <option value="3" <%= reviews2.getInt("rating")==3?"selected":"" %>>⭐ 3</option>
                <option value="2" <%= reviews2.getInt("rating")==2?"selected":"" %>>⭐ 2</option>
                <option value="1" <%= reviews2.getInt("rating")==1?"selected":"" %>>⭐ 1</option>
            </select>
        </div>

        <label class="font-medium">Edit Review</label>
        <textarea name="review_text" class="w-full border rounded-lg px-3 py-2" rows="3"><%= reviews2.getString("review_text") %></textarea>

        <div class="flex gap-3">
            <button class="bg-green-600 text-white px-4 py-2 rounded-lg">Save</button>
            <a href="SpecialistDetails.jsp?id=<%= clinicId %>"
               class="px-4 py-2 bg-gray-400 text-white rounded-lg">Cancel</a>
        </div>
    </form>

<% } else { %>
    <!-- ======================= VIEW MODE ======================= -->

    <div class="font-semibold text-lg"><%= reviews2.getString("reviewer_name") %></div>
    <div class="text-yellow-500">⭐ <%= reviews2.getInt("rating") %></div>
    <p class="mt-2"><%= reviews2.getString("review_text") %></p>

    <% if (reviews2.getInt("member_id") == memberId) { %>
        <a href="SpecialistDetails.jsp?id=<%= clinicId %>&edit=<%= reviewId %>"
           class="text-blue-600 underline mr-4">Edit</a>

        <a href="Reviews/DeleteSpecialistReview.jsp?id=<%= reviewId %>&clinic_id=<%= clinicId %>"
           onclick="return confirm('Delete review?')"
           class="text-red-600 underline">Delete</a>
    <% } %>

    <% 
        psReplies2.setInt(1, reviewId);
        ResultSet rp2 = psReplies2.executeQuery();
        while (rp2.next()) { 
    %>
        <div class="ml-6 mt-3 p-3 bg-gray-100 rounded-lg">
            <b><%= rp2.getString("replier_name") %></b>
            <p class="text-sm mt-1"><%= rp2.getString("reply_text") %></p>
        </div>
    <% } %>

<% } %>

</div>

<% } if (!anyReview2) { %>
<p class="text-gray-600 text-lg">No reviews yet.</p>
<% } %>

</div>


<script>
const clinicIdJS = "<%= clinicId %>";
document.getElementById("specialistFrame").src =
    "<%= request.getContextPath() %>/Services/Doctor/Specialist/SpecialistClinicDetailsData.jsp?id=" + clinicIdJS;


    function selectPackageIframe(id, name, basePrice, finalPrice, adjustType, adjustValue) {
        // Set hidden field
        document.getElementById("package_id").value = id;

        // Show selected package name
        document.getElementById("packageDisplay").innerText = name;

        // Show price box
        document.getElementById("priceBox").classList.remove("hidden");

        // Base Price
        document.getElementById("previewBase").innerText = basePrice.toFixed(2);

        // ======================
        // FORMAT ADJUSTMENT
        // ======================

        let adjText = "";

        if (adjustValue < 0) {
            // DISCOUNT
            if (adjustType === "FLAT") {
                adjText = "-$" + Math.abs(adjustValue).toFixed(2);
            } else {
                adjText = "-" + Math.abs(adjustValue) + "%";
            }

        } else if (adjustValue > 0) {
            // SURCHARGE
            if (adjustType === "FLAT") {
                adjText = "+$" + adjustValue.toFixed(2);
            } else {
                adjText = "+" + adjustValue + "%";
            }

        } else {
            // no adjustment
            adjText = "$0.00";
        }

        document.getElementById("previewAdj").innerText = adjText;

        // Final price
        document.getElementById("previewFinal").innerText = finalPrice.toFixed(2);
    }

</script>

</body>
</html>
