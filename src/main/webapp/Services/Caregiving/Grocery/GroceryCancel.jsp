<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

int bookingId = Integer.parseInt(request.getParameter("id"));

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "UPDATE grocery_order SET status='CANCELLED' WHERE id=? AND member_id=?"
);

ps.setInt(1, bookingId);
ps.setInt(2, memberId);

int updated = ps.executeUpdate();   // if 0, means record not found

conn.close();

// Optional logging for debugging
// out.println("UPDATED=" + updated);

response.sendRedirect("GroceryViewAppointments.jsp?msg=Cancelled");
%>
