<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
String role     = (String) session.getAttribute("type");   // <-- ADD THIS

request.setCharacterEncoding("UTF-8");

// 🔥 BLOCK ADMIN from writing/editing reviews
if ("admin".equals(role)) {
%>
<script>
alert("Admins are not allowed to submit or edit reviews.");
history.back();
</script>
<%
    return;
}

String reviewIdParam = request.getParameter("review_id");
boolean isEdit = (reviewIdParam != null && !reviewIdParam.trim().isEmpty());

int companyId = Integer.parseInt(request.getParameter("company_id"));
int rating = Integer.parseInt(request.getParameter("rating"));
String text = request.getParameter("review_text");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC"
);

/* ===========================================
   EDIT MODE → UPDATE review
=========================================== */
if (isEdit) {

    int reviewId = Integer.parseInt(reviewIdParam);

    // ownership check (admin already blocked)
    PreparedStatement chk = conn.prepareStatement(
        "SELECT COUNT(*) FROM grocery_review WHERE id=? AND member_id=?"
    );
    chk.setInt(1, reviewId);
    chk.setInt(2, memberId);
    ResultSet rs = chk.executeQuery();
    rs.next();

    if (rs.getInt(1) == 0) {
%>
<script>
alert("You can only edit your own review.");
history.back();
</script>
<%
        conn.close();
        return;
    }

    // UPDATE review
    PreparedStatement upd = conn.prepareStatement(
        "UPDATE grocery_review SET rating=?, review_text=?, created_at=NOW() WHERE id=?"
    );
    upd.setInt(1, rating);
    upd.setString(2, text);
    upd.setInt(3, reviewId);
    upd.executeUpdate();

    conn.close();
%>
<script>
alert("Review updated.");
window.location.href = "GroceryDetails.jsp?id=<%= companyId %>";
</script>
<%
return;
}

/* ===========================================
   CREATE MODE → NEW review
=========================================== */

// check if user already has a review
PreparedStatement dup = conn.prepareStatement(
    "SELECT COUNT(*) FROM grocery_review WHERE member_id=? AND company_id=?"
);
dup.setInt(1, memberId);
dup.setInt(2, companyId);
ResultSet dupRs = dup.executeQuery();
dupRs.next();

if (dupRs.getInt(1) > 0) {
%>
<script>
alert("You have already submitted a review for this provider.");
history.back();
</script>
<%
    conn.close();
    return;
}

// INSERT new review
PreparedStatement ins = conn.prepareStatement(
    "INSERT INTO grocery_review (company_id, member_id, rating, review_text, created_at) VALUES (?,?,?,?,NOW())"
);
ins.setInt(1, companyId);
ins.setInt(2, memberId);
ins.setInt(3, rating);
ins.setString(4, text);
ins.executeUpdate();

conn.close();
%>

<script>
alert("Review submitted!");
window.location.href = "GroceryDetails.jsp?id=<%= companyId %>";
</script>
