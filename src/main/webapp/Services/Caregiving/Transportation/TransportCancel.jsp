<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) {
    response.sendRedirect("/login/login.html");
    return;
}

int bookingId = Integer.parseInt(request.getParameter("id"));

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

// Cancel booking
PreparedStatement ps = conn.prepareStatement(
    "UPDATE transport_booking SET status='CANCELLED' WHERE id=? AND member_id=?"
);
ps.setInt(1, bookingId);
ps.setInt(2, memberId);

ps.executeUpdate();
conn.close();

// Redirect with notification
response.sendRedirect("ViewTransportBookings.jsp?msg=Cancelled");
%>
