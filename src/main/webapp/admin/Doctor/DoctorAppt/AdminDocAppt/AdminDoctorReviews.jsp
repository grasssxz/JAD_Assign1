<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/JAD_Assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC"
);

// JOIN doctor_review with doctor table so admin can see doctor name
String sql =
  "SELECT dr.id AS review_id, dr.rating, dr.review_text, dr.created_at, " +
  "d.name AS doctor_name, dr.member_id " +
  "FROM doctor_review dr " +
  "JOIN doctor d ON dr.doctor_id = d.id " +
  "ORDER BY dr.created_at DESC";

PreparedStatement ps = conn.prepareStatement(sql);
ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Doctor Reviews - Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<div class="max-w-6xl mx-auto mt-10 p-6 bg-white shadow-lg rounded-lg">

    <h1 class="text-3xl font-bold text-gray-800 mb-6">
        Doctor Reviews (Admin)
    </h1>
    <!-- Back to Admin Home -->
		<a href="<%= request.getContextPath() %>/admin/admin_homePage.jsp"
		   class="inline-block mb-4 px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-800">
		     Back to Admin Home
		</a>

    <!-- SUCCESS MESSAGE -->
    <% if (request.getParameter("msg") != null) { %>
        <div class="mb-4 p-3 bg-green-100 text-green-700 border border-green-300 rounded">
            <%= request.getParameter("msg") %>
        </div>
    <% } %>

    <!-- REVIEWS LOOP -->
    <div class="space-y-6">

        <% while (rs.next()) {
            int reviewId = rs.getInt("review_id");
        %>

        <div class="border p-5 rounded-lg shadow-sm bg-gray-50">

            <h2 class="text-xl font-semibold text-gray-900">
                Doctor: <%= rs.getString("doctor_name") %>
            </h2>

            <p class="mt-2 text-sm text-gray-600">
                Rating:
                <span class="font-bold text-yellow-600">
                    <%= rs.getInt("rating") %>/5
                </span>
            </p>

            <p class="mt-2 text-gray-800"><%= rs.getString("review_text") %></p>

            <p class="text-xs text-gray-500 mt-2">
                Posted on: <%= rs.getString("created_at") %>
            </p>

            <!-- DELETE REVIEW BUTTON -->
            <a href="DeleteDoctorReview.jsp?id=<%= reviewId %>"
               onclick="return confirm('Are you sure you want to delete this review?');"
               class="inline-block mt-3 text-red-600 font-semibold hover:underline">
               Delete Review
            </a>

            <!-- --- LOAD REPLIES UNDER THIS REVIEW --- -->
            <%
                PreparedStatement psR = conn.prepareStatement(
                    "SELECT id, reply_text, created_at " +
                    "FROM doctor_review_reply WHERE review_id=?"
                );
                psR.setInt(1, reviewId);
                ResultSet rsR = psR.executeQuery();
            %>

            <% if (rsR.next()) { %>
                <div class="mt-4 pl-4 border-l-4 border-blue-500">

                    <h3 class="font-semibold text-gray-700 mb-2">Replies</h3>

                    <% do { %>
                        <div class="mt-2 p-3 bg-white border rounded shadow-sm">

                            <p class="text-gray-800">
                                <%= rsR.getString("reply_text") %>
                            </p>

                            <p class="text-xs text-gray-500 mt-1">
                                Replied on: <%= rsR.getString("created_at") %>
                            </p>

                            <!-- DELETE REPLY LINK -->
                            <a href="DeleteDoctorReply.jsp?id=<%= rsR.getInt("id") %>"
                               onclick="return confirm('Delete this reply?');"
                               class="text-red-500 font-semibold text-sm hover:underline">
                               Delete Reply
                            </a>

                        </div>
                    <% } while (rsR.next()); %>

                </div>
            <% } %>

        </div>

        <% } %>

    </div>

</div>

</body>
</html>

<%
rs.close();
ps.close();
conn.close();
%>
