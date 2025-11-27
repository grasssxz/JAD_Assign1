<%@ page import="java.sql.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%
String id = request.getParameter("id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "DELETE FROM specialist_package WHERE id=?"
);
ps.setInt(1, Integer.parseInt(id));
ps.executeUpdate();

conn.close();

response.sendRedirect("ViewPackages.jsp?msg=Package deleted");
%>
