<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

Integer memberId = (Integer) session.getAttribute("member_id");
String username = (String) session.getAttribute("username");
String doctorId = request.getParameter("doctor_id");
String rating = request.getParameter("rating");
String reviewText = request.getParameter("review_text");

if (memberId == null) memberId = -1;

/* Validate doctor_id */
if (doctorId == null) {
    response.sendRedirect("DoctorDetails.jsp?id=" + doctorId + "&msg=Invalid+doctor+ID");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

/* Ensure user has appointment */
PreparedStatement allow = conn.prepareStatement(
    "SELECT 1 FROM doctor_appointment WHERE member_id=? AND doctor_id=? AND status IN ('PENDING','COMPLETED')"
);
allow.setInt(1, memberId);
allow.setString(2, doctorId);
ResultSet a = allow.executeQuery();

if (!a.next()) {
    conn.close();
    response.sendRedirect("DoctorDetails.jsp?id=" + doctorId + "&msg=You+cannot+review+without+an+appointment");
    return;
}

/* Ensure user has NOT reviewed yet */
PreparedStatement check = conn.prepareStatement(
    "SELECT 1 FROM doctor_review WHERE member_id=? AND doctor_id=?"
);
check.setInt(1, memberId);
check.setString(2, doctorId);
ResultSet c = check.executeQuery();

if (c.next()) {
    conn.close();
    response.sendRedirect("DoctorDetails.jsp?id=" + doctorId + "&msg=You+already+reviewed+this+doctor");
    return;
}

/* Insert review */
PreparedStatement ps = conn.prepareStatement(
    "INSERT INTO doctor_review (doctor_id, member_id, reviewer_name, rating, review_text) VALUES (?,?,?,?,?)"
);

ps.setString(1, doctorId);
ps.setInt(2, memberId);
ps.setString(3, username);
ps.setInt(4, Integer.parseInt(rating));
ps.setString(5, reviewText);
ps.executeUpdate();

conn.close();

response.sendRedirect("../DoctorDetails.jsp?id=" + doctorId + "&msg=Review+submitted");



%>
