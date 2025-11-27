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

/* ===========================
   FIX: prevent direct access
=========================== */
String bid = request.getParameter("booking_id");
if (bid == null || bid.trim().isEmpty()) {
    out.println("<div style='max-width:600px;margin:40px auto;padding:20px;background:#fee;border:1px solid #f88;color:#900;border-radius:10px;'>");
    out.println("<h2>Error: Missing booking_id.</h2>");
    out.println("<p>You cannot open this page directly.</p>");
    out.println("</div>");
    return;
}

int bookingId = Integer.parseInt(bid);
String newDate = request.getParameter("new_date");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "UPDATE grocery_order SET booking_date=? WHERE id=? AND member_id=?"
);

ps.setString(1, newDate);
ps.setInt(2, bookingId);
ps.setInt(3, memberId);

ps.executeUpdate();
conn.close();

response.sendRedirect("GroceryViewAppointments.jsp?msg=Rescheduled");
%>
