<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
String role     = (String) session.getAttribute("type");   // <-- IMPORTANT

request.setCharacterEncoding("UTF-8");

/* Detect if editing */
String replyIdParam = request.getParameter("reply_id");
boolean isEdit = (replyIdParam != null && !replyIdParam.trim().isEmpty());

int reviewId = Integer.parseInt(request.getParameter("review_id"));
String replyText = request.getParameter("reply_text");

/* Empty reply check */
if (replyText == null || replyText.trim().isEmpty()) {
%>
<script>
alert("Reply cannot be empty.");
history.back();
</script>
<%
    return;
}

/* ================================
   ADMIN EDIT BLOCK
   ================================ */
if ("admin".equals(role) && isEdit) {
%>
<script>
alert("Admin cannot edit replies. Only delete.");
history.back();
</script>
<%
    return;
}

/* DB Connection */
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC"
);

/* Get company_id for redirect */
PreparedStatement getComp = conn.prepareStatement(
    "SELECT company_id FROM grocery_review WHERE id=?"
);
getComp.setInt(1, reviewId);
ResultSet compRs = getComp.executeQuery();
compRs.next();

int companyId = compRs.getInt("company_id");

/* =======================================
   EDIT MODE — UPDATE REPLY (member only)
======================================= */
if (isEdit) {

    int replyId = Integer.parseInt(replyIdParam);

    // Ownership check (admin already blocked earlier)
    PreparedStatement chk = conn.prepareStatement(
        "SELECT COUNT(*) FROM grocery_review_reply WHERE id=? AND member_id=?"
    );
    chk.setInt(1, replyId);
    chk.setInt(2, memberId);
    ResultSet rsChk = chk.executeQuery();
    rsChk.next();

    if (rsChk.getInt(1) == 0) {
%>
<script>
alert("You can only edit your own reply.");
history.back();
</script>
<%
        conn.close();
        return;
    }

    // UPDATE
    PreparedStatement upd = conn.prepareStatement(
        "UPDATE grocery_review_reply SET reply_text=?, created_at=NOW() WHERE id=?"
    );
    upd.setString(1, replyText);
    upd.setInt(2, replyId);
    upd.executeUpdate();

    conn.close();
%>
<script>
alert("Reply updated.");
window.location.href = "GroceryDetails.jsp?id=<%= companyId %>";
</script>
<%
return;
}

/* =======================================
   CREATE MODE — INSERT NEW REPLY
   (Admin allowed to reply, only edit is blocked)
======================================= */
PreparedStatement ins = conn.prepareStatement(
    "INSERT INTO grocery_review_reply (review_id, member_id, reply_text, created_at) VALUES (?,?,?,NOW())"
);
ins.setInt(1, reviewId);
ins.setInt(2, memberId);
ins.setString(3, replyText);
ins.executeUpdate();

conn.close();
%>

<script>
alert("Reply posted successfully.");
window.location.href = "GroceryDetails.jsp?id=<%= companyId %>";
</script>
