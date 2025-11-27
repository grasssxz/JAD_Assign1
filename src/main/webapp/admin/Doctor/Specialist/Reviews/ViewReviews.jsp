<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />
<jsp:include page="/admin/adminNavBar.jsp" />

<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<title>Specialist Reviews</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<div class="max-w-6xl mx-auto px-6 py-10">

    <h1 class="text-3xl font-bold mb-6">Specialist Reviews</h1>

    <!-- SUCCESS MESSAGE -->
    <%
    String msg = request.getParameter("msg");
    if (msg != null) {
    %>
        <div class="bg-green-100 text-green-800 border border-green-300 px-4 py-3 rounded-lg mb-6">
            <%= msg %>
        </div>
    <% } %>

    <div class="bg-white rounded-xl shadow p-6">

        <table class="w-full text-left border-collapse">
            <thead>
                <tr class="border-b bg-gray-50">
                    <th class="p-3 font-semibold">Clinic</th>
                    <th class="p-3 font-semibold">Reviewer</th>
                    <th class="p-3 font-semibold">Rating</th>
                    <th class="p-3 font-semibold">Review</th>
                    <th class="p-3 font-semibold">Date</th>
                    <th class="p-3 font-semibold text-center">Action</th>
                </tr>
            </thead>

            <tbody>
            <%
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
                "root","1G9r5a6c1E**"
            );

            PreparedStatement ps = conn.prepareStatement(
                "SELECT r.*, m.username AS reviewer_name, c.name AS clinic_name " +
                "FROM specialist_review r " +
                "JOIN member m ON r.member_id = m.id " +
                "JOIN specialist_clinic c ON r.clinic_id = c.id " +
                "ORDER BY r.created_at DESC"
            );

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
            %>

            <tr class="border-b hover:bg-gray-50">
                <td class="p-3"><%= rs.getString("clinic_name") %></td>
                <td class="p-3"><%= rs.getString("reviewer_name") %></td>
                <td class="p-3">⭐ <%= rs.getInt("rating") %></td>
                <td class="p-3 w-80"><%= rs.getString("review_text") %></td>
                <td class="p-3"><%= rs.getTimestamp("created_at") %></td>

                <td class="p-3 text-center">
                    <a href="DeleteReviews.jsp?id=<%= rs.getInt("id") %>"
                       onclick="return confirm('Delete this review?')"
                       class="bg-red-600 text-white px-3 py-1 rounded-lg text-sm hover:bg-red-700">
                        Delete
                    </a>
                </td>
            </tr>

            <% } conn.close(); %>
            </tbody>
        </table>

    </div>
</div>

</body>
</html>
