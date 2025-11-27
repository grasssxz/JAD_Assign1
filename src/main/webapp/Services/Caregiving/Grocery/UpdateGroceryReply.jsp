<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page import="java.sql.*" %>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
String role     = (String) session.getAttribute("type");   // <-- ADD THIS

// ❗ Admin cannot edit replies
if ("admin".equals(role)) {
%>
<script>
alert("Admins are not allowed to edit replies. They can only delete.");
history.back();
</script>
<%
    return;
}

int replyId = Integer.parseInt(request.getParameter("reply_id"));
String text = request.getParameter("reply_text");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
"jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

/* Validate ownership (only members can edit) */
PreparedStatement chk = conn.prepareStatement(
    "SELECT rr.member_id, r.company_id FROM grocery_review_reply rr JOIN grocery_review r ON rr.review_id = r.id WHERE rr.id=?"
);

chk.setInt(1, replyId);
ResultSet rs = chk.executeQuery();
rs.next();

int owner = rs.getInt(1);
int companyId = rs.getInt(2);

if (owner != memberId) {
%>
<script>alert("You can only edit your own reply."); history.back();</script>
<%
conn.close();
return;
}

/* Update reply */
PreparedStatement upd = conn.prepareStatement(
    "UPDATE grocery_review_reply " +
    "SET reply_text=?, created_at=NOW() " +
    "WHERE id=?"
);

upd.setString(1, text);
upd.setInt(2, replyId);
upd.executeUpdate();

conn.close();
%>

<script>
alert("Reply updated.");
window.location.href = "GroceryDetails.jsp?id=<%= companyId %>";
</script>
