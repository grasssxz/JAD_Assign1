<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

String reviewId = request.getParameter("id");
String doctorId = request.getParameter("doctor_id");
Integer memberId = (Integer) session.getAttribute("member_id");

if (reviewId == null || doctorId == null) {
    out.println("Invalid review");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

/* Load review */
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM doctor_review WHERE id=? AND member_id=?"
);
ps.setString(1, reviewId);
ps.setInt(2, memberId);
ResultSet rs = ps.executeQuery();

if (!rs.next()) {
    conn.close();
    out.println("<div class='p-4 text-red-600'>Review not found.</div>");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-6">

<div class="max-w-xl mx-auto bg-white shadow p-6 rounded-xl">
<h2 class="text-xl font-bold mb-4">Edit Review</h2>

<form method="post">

    <label class="font-medium">Rating</label>
    <select name="rating" class="border rounded-lg px-3 py-2 mb-3">
        <option <%= rs.getInt("rating")==5?"selected":"" %> value="5">⭐ 5</option>
        <option <%= rs.getInt("rating")==4?"selected":"" %> value="4">⭐ 4</option>
        <option <%= rs.getInt("rating")==3?"selected":"" %> value="3">⭐ 3</option>
        <option <%= rs.getInt("rating")==2?"selected":"" %> value="2">⭐ 2</option>
        <option <%= rs.getInt("rating")==1?"selected":"" %> value="1">⭐ 1</option>
    </select>

    <label class="font-medium block mt-3">Review</label>
    <textarea name="review_text" rows="4"
              class="border rounded-lg w-full px-3 py-2 mb-3"><%= rs.getString("review_text") %></textarea>

    <button class="bg-blue-600 text-white px-4 py-2 rounded-lg">Save Changes</button>
</form>

</div>

</body>
</html>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String rating = request.getParameter("rating");
    String reviewText = request.getParameter("review_text");

    PreparedStatement update = conn.prepareStatement(
        "UPDATE doctor_review SET rating=?, review_text=? WHERE id=? AND member_id=?"
    );

    update.setInt(1, Integer.parseInt(rating));
    update.setString(2, reviewText);
    update.setString(3, reviewId);
    update.setInt(4, memberId);
    update.executeUpdate();

    conn.close();

    response.sendRedirect("../DoctorDetails.jsp?id=" + doctorId + "&msg=Review+updated");



}
%>
