<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<!DOCTYPE html>
<html>
<head>
<title>Admin – Doctor Reviews</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<div class="max-w-5xl mx-auto mt-10 bg-white p-6 shadow rounded-lg">

    <h1 class="text-3xl font-bold mb-6">Doctor Reviews Management</h1>

<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

/* Load all reviews with doctor + reviewer */
PreparedStatement ps = conn.prepareStatement(
    "SELECT r.*, d.name AS doctor_name " +
    "FROM doctor_review r " +
    "JOIN doctor d ON r.doctor_id = d.id " +
    "ORDER BY r.created_at DESC"
);

ResultSet rs = ps.executeQuery();
%>

<table class="w-full border-collapse">
<tr class="bg-gray-200 text-left">
    <th class="p-2">Doctor</th>
    <th class="p-2">Reviewer</th>
    <th class="p-2">Rating</th>
    <th class="p-2">Review</th>
    <th class="p-2">Replies</th>
    <th class="p-2">Actions</th>
</tr>

<%
while (rs.next()) {
    int reviewId = rs.getInt("id");
%>

<tr class="border-b align-top">
    <td class="p-2"><%= rs.getString("doctor_name") %></td>
    <td class="p-2"><%= rs.getString("reviewer_name") %></td>
    <td class="p-2">⭐ <%= rs.getInt("rating") %></td>
    <td class="p-2"><%= rs.getString("review_text") %></td>

    <!-- Replies -->
    <td class="p-2">
        <%
        PreparedStatement psRep = conn.prepareStatement(
            "SELECT * FROM doctor_review_reply WHERE review_id=? ORDER BY created_at ASC"
        );
        psRep.setInt(1, reviewId);
        ResultSet rep = psRep.executeQuery();

        boolean hasReplies = false;
        while (rep.next()) {
            hasReplies = true;
        %>

        <div class="border p-2 rounded mb-2 bg-gray-50">
            <b><%= rep.getString("replier_name") %></b>:
            <%= rep.getString("reply_text") %>

            <br>
            <a href="DeleteReply.jsp?id=<%= rep.getInt("id") %>"
               class="text-red-600 text-sm">
               Delete Reply
            </a>
        </div>

        <% }
        if (!hasReplies) { %>
            <i class="text-gray-500">No replies</i>
        <% } %>
    </td>

    <!-- Actions -->
    <td class="p-2">
        <a href="DeleteReview.jsp?id=<%= reviewId %>"
           class="px-3 py-1 bg-red-600 text-white rounded-lg">
            Delete Review
        </a>
    </td>

</tr>

<%
} // end while
conn.close();
%>

</table>

</div>
</body>
</html>
