<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page import="java.sql.*" %>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
String role = (String) session.getAttribute("type");   // <-- ADD THIS

int replyId = Integer.parseInt(request.getParameter("reply_id"));

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

/* Validate ownership AND fetch company_id for redirect */
PreparedStatement chk = conn.prepareStatement(
    "SELECT rr.member_id, r.company_id " +
    "FROM grocery_review_reply rr " +
    "JOIN grocery_review r ON rr.review_id = r.id " +
    "WHERE rr.id=?"
);

chk.setInt(1, replyId);
ResultSet rs = chk.executeQuery();

if (!rs.next()) {
%>
<script>alert("Reply not found."); history.back();</script>
<%
    conn.close();
    return;
}

int owner = rs.getInt(1);
int companyId = rs.getInt(2);

/*  Admin allowed to delete ANY reply */
if (owner != memberId && !"admin".equals(role)) {
%>
<script>alert("You can only delete your own reply."); history.back();</script>
<%
    conn.close();
    return;
}

/* Delete */
PreparedStatement del = conn.prepareStatement(
    "DELETE FROM grocery_review_reply WHERE id=?"
);
del.setInt(1, replyId);
del.executeUpdate();

conn.close();
%>

<script>
alert("Reply deleted.");
window.location.href = "GroceryDetails.jsp?id=<%= companyId %>";
</script>
