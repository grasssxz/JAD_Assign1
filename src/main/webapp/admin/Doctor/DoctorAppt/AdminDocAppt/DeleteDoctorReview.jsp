<%@ page import="java.sql.*" %>
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%
int reviewId = Integer.parseInt(request.getParameter("id"));

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/JAD_Assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC"
);

// 1. Delete all replies linked to this review
PreparedStatement ps1 = conn.prepareStatement(
    "DELETE FROM doctor_review_reply WHERE review_id=?"
);
ps1.setInt(1, reviewId);
ps1.executeUpdate();

// 2. Then delete the review
PreparedStatement ps2 = conn.prepareStatement(
    "DELETE FROM doctor_review WHERE id=?"
);
ps2.setInt(1, reviewId);
ps2.executeUpdate();

ps1.close();
ps2.close();
conn.close();

response.sendRedirect("AdminDoctorReviews.jsp?msg=Review+deleted");
%>
