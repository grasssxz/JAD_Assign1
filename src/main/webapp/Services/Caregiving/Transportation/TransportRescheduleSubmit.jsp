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

// Correct parameter name: booking_id
String bid = request.getParameter("booking_id");
String newDate = request.getParameter("new_date");

// Validation
if (bid == null || bid.trim().isEmpty() || newDate == null) {
    out.println("<h2 style='color:red;text-align:center;margin-top:40px;'>Missing booking_id.</h2>");
    return;
}

int bookingId = Integer.parseInt(bid);

// DB Connection
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

// Check for clashing booking
PreparedStatement clash = conn.prepareStatement(
    "SELECT COUNT(*) AS cnt FROM transport_booking " +
    "WHERE member_id = ? AND booking_date = ? AND status!='CANCELLED'"
);
clash.setInt(1, memberId);
clash.setString(2, newDate);

ResultSet crs = clash.executeQuery();
crs.next();

if (crs.getInt("cnt") > 0) {
%>
<script>
    alert("You already have a transport booking on this date.");
    window.history.back();
</script>
<%
    return;
}

// Update booking
PreparedStatement upd = conn.prepareStatement(
    "UPDATE transport_booking SET booking_date=? WHERE id=? AND member_id=?"
);
upd.setString(1, newDate);
upd.setInt(2, bookingId);
upd.setInt(3, memberId);
upd.executeUpdate();

conn.close();

// SUCCESS REDIRECT
response.sendRedirect("ViewTransportBookings.jsp?msg=Rescheduled");
%>
