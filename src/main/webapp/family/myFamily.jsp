<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";

Connection conn = DriverManager.getConnection(connURL);

String ctx = request.getContextPath();

// get logged in member
Integer memberIdObj = (Integer) session.getAttribute("member_id");
String username = (String) session.getAttribute("username");

if (memberIdObj == null || username == null) {
    response.sendRedirect(ctx + "/login/login.html");
    return;
}

int memberId = memberIdObj;

/* ==========================================================
   FIXED: Retrieve family_id safely (handles MySQL Long type)
========================================================== */
Integer familyId = null;

PreparedStatement psMe = conn.prepareStatement(
    "SELECT family_id FROM member WHERE id = ?"
);
psMe.setInt(1, memberId);
ResultSet rsMe = psMe.executeQuery();

if (rsMe.next()) {
    int fid = rsMe.getInt("family_id");   // SAFE
    if (!rsMe.wasNull()) {
        familyId = fid;
    }
}

rsMe.close();
psMe.close();


/* ==========================================================
   Get family members
========================================================== */
String message = null;
List<Integer> famIds = new ArrayList<>();
List<String> famUsernames = new ArrayList<>();
List<String> famEmails = new ArrayList<>();

if (familyId != null) {

    PreparedStatement psFam = conn.prepareStatement(
        "SELECT id, username, email FROM member " +
        "WHERE family_id = ? AND status = 'activated' ORDER BY username"
    );
    psFam.setInt(1, familyId);
    ResultSet rsFam = psFam.executeQuery();

    while (rsFam.next()) {
        famIds.add(rsFam.getInt("id"));
        famUsernames.add(rsFam.getString("username"));
        famEmails.add(rsFam.getString("email"));
    }

    rsFam.close();
    psFam.close();

} else {
    message = "You are not in a family yet. Go to Me Page to create or join one.";
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Family</title>
<style>
body{font-family:Arial;background:#f6f7fb;margin:0;padding:0}
.container{max-width:800px;margin:20px auto;background:#fff;padding:20px;border-radius:14px;box-shadow:0 3px 10px rgba(0,0,0,0.1)}
table{width:100%;border-collapse:collapse;margin-top:15px}
th,td{border:1px solid #eee;padding:8px;text-align:left}
th{background:#eef0ff}
.btn-small{
  background:#7f9cf5;
  color:white;
  padding:6px 10px;
  border-radius:6px;
  text-decoration:none;
  font-size:13px;
}
.btn-small:hover{background:#5e7ce0}
.msg{margin-top:10px;color:#c0392b;font-weight:600}
</style>
</head>

<body>

<jsp:include page="/home/NavBar.jsp"/>

<div class="container">
  <h2>My Family</h2>
  <p>Logged in as: <strong><%= username %></strong> (Member ID: <%= memberId %>)</p>

  <% if (message != null) { %>

      <div class="msg"><%= message %></div>

  <% } else { %>

      <% if (famIds.isEmpty()) { %>

          <p>No active family members found.</p>

      <% } else { %>

          <table>
            <tr>
              <th>Member ID</th>
              <th>Username</th>
              <th>Email</th>
              <th>Actions</th>
            </tr>

            <% for (int i = 0; i < famIds.size(); i++) { %>
              <tr>
                <td><%= famIds.get(i) %></td>
                <td><%= famUsernames.get(i) %></td>
                <td><%= famEmails.get(i) %></td>
                <td>
                  <a class="btn-small"
                     href="<%= ctx %>/family/showFamilyBooking.jsp?memberId=<%= famIds.get(i) %>">
                    View bookings
                  </a>
                </td>
              </tr>
            <% } %>

          </table>

      <% } %>

  <% } %>
</div>

<%
conn.close();
%>

</body>
</html>
