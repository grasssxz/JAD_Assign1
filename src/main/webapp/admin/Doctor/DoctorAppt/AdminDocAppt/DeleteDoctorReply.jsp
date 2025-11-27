<%@ page import="java.sql.*" %>
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%
int replyId = Integer.parseInt(request.getParameter("id"));

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/JAD_Assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC"
);

PreparedStatement ps = conn.prepareStatement(
    "DELETE FROM doctor_review_reply WHERE id=?"
);
ps.setInt(1, replyId);
ps.executeUpdate();
ps.close();
conn.close();

response.sendRedirect("AdminDoctorReviews.jsp?msg=Reply+deleted");
%>
