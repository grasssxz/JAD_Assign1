<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<%
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true";
Class.forName("com.mysql.cj.jdbc.Driver");

// Session info
String role = (String) session.getAttribute("type");
Integer sessionMemberId = (Integer) session.getAttribute("member_id");

if (role == null) role = "guest";

// Block guests
if ("guest".equalsIgnoreCase(role) || (sessionMemberId == null && !"admin".equalsIgnoreCase(role))) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

// parameters
String action = request.getParameter("action");
String deleteId = request.getParameter("id");
String searchMember = request.getParameter("member_id");
String message = null;

/* ===============================
   DELETE BOOKING
   - member: only delete own booking
   - admin: delete any booking
================================*/
if ("delete".equals(action) && deleteId != null) {
    try (Connection connDel = DriverManager.getConnection(connURL)) {

        if ("admin".equalsIgnoreCase(role)) {
            PreparedStatement ps = connDel.prepareStatement(
                "DELETE FROM transport_booking WHERE id=?"
            );
            ps.setInt(1, Integer.parseInt(deleteId));
            ps.executeUpdate();
            ps.close();
        } else {
            PreparedStatement ps = connDel.prepareStatement(
                "DELETE FROM transport_booking WHERE id=? AND member_id=?"
            );
            ps.setInt(1, Integer.parseInt(deleteId));
            ps.setInt(2, sessionMemberId);
            int rows = ps.executeUpdate();
            ps.close();

            if (rows == 0) message = "You can only delete your own bookings.";
        }

    } catch (Exception e) {
        message = "Delete failed: " + e.getMessage();
    }

    // redirect to refresh list
    if ("admin".equals(role) && searchMember != null && !searchMember.trim().isEmpty()) {
        response.sendRedirect("viewTransportBooking.jsp?member_id=" + searchMember.trim());
    } else {
        response.sendRedirect("viewTransportBooking.jsp");
    }
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Transport Bookings</title>

<style>
body { font-family: Arial; padding:20px; background:#f6f7fb; }
h2 { color:#4f46e5; margin-top:10px; }
table { border-collapse:collapse; width:100%; margin-top:16px; background:#fff; }
th, td { border:1px solid #ddd; padding:10px; }
th { background:#eef; }
.controls {
  margin-top:12px; padding:12px; background:#fff;
  border-radius:8px; display:flex; gap:12px; align-items:center;
}
input[type=text] { padding:6px; width:180px; }
button {
  padding:6px 12px; background:#4f46e5; color:white; border:0;
  border-radius:6px; cursor:pointer;
}
.btn-del {
  background:#e11d48; color:white; padding:6px 10px;
  text-decoration:none; border-radius:6px; display:inline-block;
}
.btn-del:hover { background:#be123c; }
.back-btn {
  display:inline-block; padding:8px 14px; margin-bottom:8px;
  background:#64748b; color:white; text-decoration:none; border-radius:6px;
}
.msg { margin-top:10px; color:#b91c1c; font-weight:600; }
.note { color:#666; font-size:14px; }
.badge { padding:2px 8px; border-radius:10px; font-size:12px; color:white; }
.badge-pending { background:#f59e0b; }
.badge-confirmed { background:#3b82f6; }
.badge-inprogress { background:#a855f7; }
.badge-completed { background:#16a34a; }
.badge-cancelled { background:#dc2626; }
</style>
</head>

<body>

<% if ("admin".equals(role)) { %>
  <a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp" class="back-btn">← Back to Admin Home</a>
<% } else { %>
  <a href="<%=request.getContextPath()%>/home/HomePage.jsp" class="back-btn">← Back to Home</a>
<% } %>

<h2><%= "admin".equals(role) ? "All Transport Bookings" : "My Transport Bookings" %></h2>

<% if (message != null) { %>
  <div class="msg"><%= message %></div>
<% } %>

<!-- ADMIN SEARCH BAR -->
<% if ("admin".equals(role)) { %>
<form class="controls" method="get" action="viewTransportBooking.jsp">
  <label><b>Search by Member ID:</b></label>
  <input type="text" name="member_id"
         value="<%= searchMember != null ? searchMember : "" %>"
         placeholder="e.g. 5">
  <button type="submit">Search</button>
  <a class="note" href="viewTransportBooking.jsp">Clear</a>
</form>
<% } %>

<%
/* ===============================
   LIST BOOKINGS
================================*/
String sql =
  "SELECT tb.id, tb.member_id, tb.provider_id, tb.booking_date, tb.total_fee, tb.status, tb.created_at, " +
  "       tp.name AS provider_name " +
  "FROM transport_booking tb " +
  "JOIN transport_provider tp ON tb.provider_id = tp.id ";

boolean adminSearchActive = "admin".equals(role)
                            && searchMember != null
                            && !searchMember.trim().isEmpty();

if ("admin".equals(role)) {
    if (adminSearchActive) sql += "WHERE tb.member_id = ? ";
} else {
    sql += "WHERE tb.member_id = ? ";
}

sql += "ORDER BY tb.created_at DESC";

try (Connection conn = DriverManager.getConnection(connURL);
     PreparedStatement ps = conn.prepareStatement(sql)) {

    if ("admin".equals(role)) {
        if (adminSearchActive) ps.setInt(1, Integer.parseInt(searchMember.trim()));
    } else {
        ps.setInt(1, sessionMemberId);
    }

    ResultSet rs = ps.executeQuery();
%>

<table>
  <tr>
    <th>ID</th>
    <th>Member ID</th>
    <th>Provider</th>
    <th>Booking Date</th>
    <th>Total Fee</th>
    <th>Status</th>
    <th>Created</th>
    <th>Action</th>
  </tr>

<%
boolean hasRows = false;
while (rs.next()) {
    hasRows = true;
    String st = rs.getString("status");
%>
  <tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getInt("member_id") %></td>
    <td><%= rs.getInt("provider_id") %> - <%= rs.getString("provider_name") %></td>
    <td><%= rs.getDate("booking_date") %></td>
    <td>$<%= rs.getBigDecimal("total_fee") %></td>

    <td>
      <% if ("PENDING".equalsIgnoreCase(st)) { %>
        <span class="badge badge-pending">pending</span>
      <% } else if ("CONFIRMED".equalsIgnoreCase(st)) { %>
        <span class="badge badge-confirmed">confirmed</span>
      <% } else if ("IN_PROGRESS".equalsIgnoreCase(st)) { %>
        <span class="badge badge-inprogress">in progress</span>
      <% } else if ("COMPLETED".equalsIgnoreCase(st)) { %>
        <span class="badge badge-completed">completed</span>
      <% } else { %>
        <span class="badge badge-cancelled">cancelled</span>
      <% } %>
    </td>

    <td><%= rs.getTimestamp("created_at") %></td>

    <td>
      <a class="btn-del"
         onclick="return confirm('Delete this transport booking?');"
         href="viewTransportBooking.jsp?action=delete&id=<%=rs.getInt("id")%><%= adminSearchActive ? "&member_id=" + searchMember.trim() : "" %>">
         Delete
      </a>
    </td>
  </tr>
<%
}

if (!hasRows) {
%>
  <tr>
    <td colspan="8" style="text-align:center; color:#666;">No transport bookings found.</td>
  </tr>
<%
}
%>

</table>

<%
} catch (Exception e) {
    out.println("<p style='color:red'>List error: " + e.getMessage() + "</p>");
}
%>

</body>
</html>
