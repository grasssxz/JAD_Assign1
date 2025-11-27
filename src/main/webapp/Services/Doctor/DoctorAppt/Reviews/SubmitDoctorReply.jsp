<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

Integer memberId = (Integer) session.getAttribute("member_id");
String username = (String) session.getAttribute("username");

String doctorId = request.getParameter("doctor_id");
String reviewId = request.getParameter("review_id");
String replyText = request.getParameter("reply_text");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

/* Insert reply */
PreparedStatement ps = conn.prepareStatement(
    "INSERT INTO doctor_review_reply (review_id, member_id, replier_name, reply_text) VALUES (?,?,?,?)"
);
ps.setString(1, reviewId);
ps.setInt(2, memberId);
ps.setString(3, username);
ps.setString(4, replyText);
ps.executeUpdate();

conn.close();

response.sendRedirect("../DoctorDetails.jsp?id=" + doctorId + "&msg=Reply+submitted");



%>
