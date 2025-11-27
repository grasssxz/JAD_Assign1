<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
String id = request.getParameter("id");
Integer memberId = (Integer) session.getAttribute("member_id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "UPDATE specialist_appointment SET status='cancelled' WHERE id=? AND member_id=?"
);
ps.setString(1, id);
ps.setInt(2, memberId);
ps.executeUpdate();

conn.close();

response.sendRedirect("MyAppointments.jsp?msg=Appointment Cancelled");
%>
