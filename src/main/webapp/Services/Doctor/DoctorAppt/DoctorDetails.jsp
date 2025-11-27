<jsp:include page="/auth/SessisonInit.jsp" />


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8" />
<title>Doctor Details</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<div class="max-w-6xl mx-auto px-5 py-6">

    <h1 class="text-3xl font-bold text-gray-800 mb-6">Doctor Details</h1>

    <div class="space-y-8">

        <!-- ============================================
             IFRAME (doctor info + packages ONLY)
        ============================================= -->
        <iframe id="doctorFrame"
                class="w-full h-[700px] bg-white rounded-xl shadow border">
        </iframe>

        <!-- ============================================
             BOOK APPOINTMENT
        ============================================= -->
        <%
        String msg = request.getParameter("msg");
        if (msg != null && !msg.trim().equals("")) {
        %>
            <div class="max-w-3xl mx-auto mt-4">
                <div class="bg-red-100 text-red-800 border border-red-300 px-4 py-3 rounded-lg shadow">
                    <%= msg %>
                </div>
            </div>
        <%
        }
        %>

        <div class="bg-white shadow p-6 rounded-xl">
            <h2 class="text-2xl font-semibold mb-4">Book Appointment</h2>

            <form action="DoctorBooking.jsp" method="post" class="space-y-4">
                <input type="hidden" id="doctorIdField" name="doctor_id" />

                <div>
                    <label>Date</label>
                    <input type="date" name="appointment_date" class="w-full border rounded-lg px-4 py-2" required />
                </div>

                <div>
                    <label>Time</label>
                    <input type="time" name="appointment_time" class="w-full border rounded-lg px-4 py-2" required />
                </div>

                <div id="pricePreview" class="hidden mt-4 p-4 bg-blue-50 rounded-lg border border-blue-300">
                    <p><b>Base Price:</b> $<span id="previewBase"></span></p>
                    <p><b>Adjustment:</b> <span id="previewAdj"></span></p>
                    <p><b>Final Price:</b> $<span id="previewFinal"></span></p>
                </div>

                <div>
                    <label>Package</label>
                    <div id="packageDisplay" class="w-full p-3 border rounded-lg bg-gray-100">
                        No package selected.
                    </div>
                    <input type="hidden" id="packageHidden" name="package_id">
                </div>

                <button class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-lg">
                    Confirm Booking
                </button>
            </form>
        </div>
    </div>
</div>

<!-- =========================================================
     REVIEWS SECTION — NOW OUTSIDE IFRAME (Final)
========================================================= -->

<%
    String id = request.getParameter("id");

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
        "root","1G9r5a6c1E**"
    );

    Integer memberId = (Integer) session.getAttribute("member_id");
    if (memberId == null) memberId = -1;

    PreparedStatement allow = conn.prepareStatement(
        "SELECT 1 FROM doctor_appointment WHERE member_id=? AND doctor_id=? AND status IN ('PENDING','COMPLETED')"
    );
    allow.setInt(1, memberId);
    allow.setString(2, id);
    boolean canReview = allow.executeQuery().next();

    PreparedStatement check = conn.prepareStatement(
        "SELECT 1 FROM doctor_review WHERE member_id=? AND doctor_id=?"
    );
    check.setInt(1, memberId);
    check.setString(2, id);
    boolean hasMyReview = check.executeQuery().next();

    PreparedStatement psReviews = conn.prepareStatement(
        "SELECT * FROM doctor_review WHERE doctor_id=? ORDER BY created_at DESC"
    );
    psReviews.setString(1, id);
    ResultSet reviews = psReviews.executeQuery();

    PreparedStatement psReplies = conn.prepareStatement(
        "SELECT * FROM doctor_review_reply WHERE review_id=? ORDER BY created_at ASC"
    );
%>

<div class="max-w-6xl mx-auto px-5 mt-14">

    <h2 class="text-3xl font-bold mb-6">Reviews</h2>

    <% if (canReview && !hasMyReview) { %>
    <form method="post"action="Reviews/SubmitDoctorReview.jsp"
 class="mb-6 p-4 border rounded-lg bg-gray-50">
        <input type="hidden" name="doctor_id" value="<%= id %>">

        <label>Rating</label>
        <select name="rating" class="border rounded-lg px-3 py-2 mb-3">
            <option value="5">⭐ 5</option>
            <option value="4">⭐ 4</option>
            <option value="3">⭐ 3</option>
            <option value="2">⭐ 2</option>
            <option value="1">⭐ 1</option>
        </select>

        <label>Review</label>
        <textarea name="review_text" class="w-full border rounded-lg px-3 py-2 mb-3" rows="3"></textarea>

        <button class="bg-blue-600 text-white px-4 py-2 rounded-lg">Submit</button>
    </form>
    <% } %>

    <%
    boolean hasReview = false;
    while (reviews.next()) {
        hasReview = true;
        int reviewId = reviews.getInt("id");
    %>

    <div class="mb-10 pb-6 border-b">
        <div class="font-semibold text-lg"><%= reviews.getString("reviewer_name") %></div>
        <div class="text-yellow-500">⭐ <%= reviews.getInt("rating") %></div>

        <p class="mt-2"><%= reviews.getString("review_text") %></p>

        <% if (reviews.getInt("member_id") == memberId) { %>
            <a href="Reviews/EditDoctorReview.jsp?id=<%= reviewId %>&doctor_id=<%= id %>"
               class="text-blue-600 underline mr-4">Edit</a>

            <a href="Reviews/DeleteDoctorReview.jsp?id=<%= reviewId %>&doctor_id=<%= id %>"
               onclick="return confirm('Delete review?')"
               class="text-red-600 underline">Delete</a>
        <% } %>

        <% 
        psReplies.setInt(1, reviewId);
        ResultSet replies = psReplies.executeQuery();
        while (replies.next()) { 
        %>
            <div class="ml-6 mt-3 p-3 bg-gray-100 rounded-lg">
                <b><%= replies.getString("replier_name") %></b>
                <p class="text-sm mt-1"><%= replies.getString("reply_text") %></p>
            </div>
        <% } %>

        <form method="post" action="Reviews/SubmitDoctorReply.jsp" class="ml-6 mt-3">
            <input type="hidden" name="review_id" value="<%= reviewId %>">
            <input type="hidden" name="doctor_id" value="<%= id %>">

            <textarea name="reply_text" rows="2" class="w-full border rounded-lg px-3 py-2 mb-2"></textarea>
            <button class="bg-blue-600 text-white px-3 py-1 rounded-lg text-sm">Reply</button>
        </form>
    </div>

    <% } %>

    <% if (!hasReview) { %>
        <p class="text-gray-600 text-lg">No reviews yet.</p>
    <% } %>

</div>

<script>
const doctorId = new URLSearchParams(window.location.search).get("id");
document.getElementById("doctorIdField").value = doctorId;

window.onload = () => {
    document.getElementById("doctorFrame").src =
        "<%= request.getContextPath() %>/Services/Doctor/DoctorAppt/DoctorDetailsData.jsp?id=" + doctorId;
};

function selectPackageFromIframe(id, label) {
    document.getElementById("packageDisplay").textContent = label;
    document.getElementById("packageHidden").value = id;
}

function updatePrice(base, type, val) {
    let f = base;
    if (type === "FLAT") f += val;
    if (type === "PERCENT") f += base * val / 100;
    document.getElementById("previewFinal").textContent = f.toFixed(2);
}
</script>

</body>
</html>
