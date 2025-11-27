<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

Integer memberId = (Integer) session.getAttribute("member_id");
String clinicId  = request.getParameter("clinic_id");
String rating    = request.getParameter("rating");
String text      = request.getParameter("review_text");

if (memberId == null || clinicId == null || rating == null) {
    response.sendRedirect("../SpecialistDetails.jsp?id=" + clinicId + "&msg=Invalid review.");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

// Prevent duplicate reviews
PreparedStatement check = conn.prepareStatement(
    "SELECT id FROM specialist_review WHERE member_id=? AND clinic_id=?"
);
check.setInt(1, memberId);
check.setString(2, clinicId);

if (check.executeQuery().next()) {
    response.sendRedirect("../SpecialistDetails.jsp?id=" + clinicId + "&msg=You already reviewed this clinic.");
    return;
}

// Insert review
PreparedStatement ps = conn.prepareStatement(
    "INSERT INTO specialist_review (member_id, clinic_id, rating, review_text) " +
    "VALUES (?,?,?,?)"
);

ps.setInt(1, memberId);
ps.setInt(2, Integer.parseInt(clinicId));
ps.setInt(3, Integer.parseInt(rating));
ps.setString(4, text);

ps.executeUpdate();
conn.close();

response.sendRedirect("../SpecialistDetails.jsp?id=" + clinicId + "&msg=Review submitted.");
%>
