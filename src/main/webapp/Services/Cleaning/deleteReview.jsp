<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
String ctx = request.getContextPath();

/* ==== AUTH GUARD ==== */
Integer memberIdObj = (Integer) session.getAttribute("member_id");
if (memberIdObj == null) {
    response.sendRedirect(ctx + "/login/login.html");
    return;
}
int memberId = memberIdObj;

/* ==== READ PARAMS ==== */
int reviewId       = Integer.parseInt(request.getParameter("reviewId"));
String ctParam     = request.getParameter("cleaningTypeId");
int cleaningTypeId = (ctParam != null && !ctParam.isEmpty())
                     ? Integer.parseInt(ctParam)
                     : 1;  // default back to housekeeping if missing

/* ==== DB ==== */

Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";
Connection conn = DriverManager.getConnection(connURL);

/* Only delete if this review belongs to the logged-in member */
PreparedStatement psDel = conn.prepareStatement(
    "DELETE FROM cleaning_review WHERE id = ? AND member_id = ?"
);
psDel.setInt(1, reviewId);
psDel.setInt(2, memberId);
psDel.executeUpdate();
psDel.close();
conn.close();

/* Redirect back to the appropriate cleaning page */
if (cleaningTypeId == 1) {
    response.sendRedirect(ctx + "/Services/Cleaning/HouseKeeping.jsp");
} else if (cleaningTypeId == 2) {
    response.sendRedirect(ctx + "/Services/Cleaning/springCleaning.jsp");
} else if (cleaningTypeId == 3) {
    response.sendRedirect(ctx + "/Services/Cleaning/postRenovation.jsp");
} else {
    // fallback
    response.sendRedirect(ctx + "/Services/Cleaning/HouseKeeping.jsp");
}
%>
