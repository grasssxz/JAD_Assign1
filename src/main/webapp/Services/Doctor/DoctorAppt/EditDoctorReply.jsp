<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

String replyId = request.getParameter("id");
String doctorId = request.getParameter("doctor_id");
Integer memberId = (Integer) session.getAttribute("member_id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

/* Load reply */
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM doctor_review_reply WHERE id=? AND member_id=?"
);
ps.setString(1, replyId);
ps.setInt(2, memberId);
ResultSet rs = ps.executeQuery();

if (!rs.next()) {
    out.println("<p class='text-red-600'>Reply not found.</p>");
    return;
}
%>

<!DOCTYPE html>
<html>
<head><script src="https://cdn.tailwindcss.com"></script></head>
<body class="p-6 bg-gray-100">

<div class="max-w-xl mx-auto bg-white shadow p-6 rounded-xl">
<h2 class="text-xl font-bold mb-4">Edit Reply</h2>

<form method="post">
<textarea name="reply_text" rows="3" class="w-full border rounded-lg px-3 py-2 mb-3"><%= rs.getString("reply_text") %></textarea>
<button class="bg-blue-600 text-white px-4 py-2 rounded-lg">Save</button>
</form>

</div>

</body>
</html>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {

    String text = request.getParameter("reply_text");

    PreparedStatement update = conn.prepareStatement(
        "UPDATE doctor_review_reply SET reply_text=? WHERE id=? AND member_id=?"
    );
    update.setString(1, text);
    update.setString(2, replyId);
    update.setInt(3, memberId);
    update.executeUpdate();

    conn.close();

    response.sendRedirect("../DoctorDetails.jsp?id=" + doctorId + "&msg=Reply+updated");



}
%>
