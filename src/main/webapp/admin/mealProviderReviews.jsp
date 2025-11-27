<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<!-- TAILWIND -->
<script src="https://cdn.tailwindcss.com"></script>

<%
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true";

Class.forName("com.mysql.cj.jdbc.Driver");

String action = request.getParameter("action");
String selectedProviderId = request.getParameter("provider_id");
String searchMember = request.getParameter("member_id");
String deleteId = request.getParameter("id");

/* ==============================================
   DELETE REVIEW (retain filters)
================================================*/
if ("delete".equals(action) && deleteId != null) {
    try (Connection connDel = DriverManager.getConnection(connURL);
         PreparedStatement psDel = connDel.prepareStatement(
             "DELETE FROM reviews WHERE id=?"
         )) {
        psDel.setInt(1, Integer.parseInt(deleteId));
        psDel.executeUpdate();
    }

    String redirect = "mealProviderReviews.jsp";
    redirect += "?provider_id=" + selectedProviderId;
    if (searchMember != null && !searchMember.trim().isEmpty())
        redirect += "&member_id=" + searchMember;

    response.sendRedirect(redirect);
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Meal Provider Reviews</title>
</head>

<body class="bg-gray-100 p-6">

<!-- Back Button -->
<a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp"
   class="inline-block mb-6 px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-900">
   ← Back to Admin Home
</a>

<h2 class="text-3xl font-bold text-indigo-700 mb-6">Meal Provider Reviews</h2>

<!-- Filter Controls -->
<div class="bg-white shadow-md p-6 rounded-xl mb-6">

    <form method="get" action="mealProviderReviews.jsp"
          class="grid grid-cols-1 lg:grid-cols-3 gap-6">

        <!-- Provider Select -->
        <div>
            <label class="block text-gray-700 font-semibold mb-1">Select Meal Provider</label>
            <select name="provider_id" required
                class="w-full border rounded-lg p-2 focus:ring-indigo-500 focus:border-indigo-600">

                <option value="">-- Choose Provider --</option>

                <%
                try (Connection connProv = DriverManager.getConnection(connURL);
                     PreparedStatement psProv = connProv.prepareStatement(
                         "SELECT id, name FROM meal_provider WHERE is_active=1 ORDER BY name"
                     );
                     ResultSet rp = psProv.executeQuery()) {

                    while (rp.next()) {
                        String pid = rp.getString("id");
                        String pname = rp.getString("name");
                        String sel = pid.equals(selectedProviderId) ? "selected" : "";
                %>
                    <option value="<%=pid%>" <%=sel%>><%=pid%> - <%=pname%></option>
                <%
                    }
                } catch (Exception e) {
                    out.println("<p class='text-red-600'>Provider error: " + e.getMessage() + "</p>");
                }
                %>

            </select>
        </div>

        <!-- Member Search -->
        <div>
            <label class="block text-gray-700 font-semibold mb-1">Filter by Member ID</label>
            <input type="text" name="member_id"
                   value="<%= (searchMember != null ? searchMember : "") %>"
                   placeholder="e.g. 3"
                   class="w-full border rounded-lg p-2 focus:ring-indigo-500 focus:border-indigo-600">
        </div>

        <!-- Submit -->
        <div class="flex items-end">
            <button type="submit"
                    class="w-full py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-800">
                Show Reviews
            </button>
        </div>

    </form>

    <p class="text-sm text-gray-500 mt-3">* Select provider first. Member ID filter is optional.</p>
</div>

<%
/* ==============================================
   SHOW REVIEWS IF PROVIDER SELECTED
================================================*/
if (selectedProviderId != null && !selectedProviderId.trim().isEmpty()) {

    String sql =
      "SELECT r.id AS review_id, r.member_id, r.rating, r.review_text, r.created_at, " +
      "       m.meal_name, m.price, mp.name AS provider_name " +
      "FROM reviews r " +
      "JOIN meal m ON r.meal_id = m.id " +
      "JOIN meal_provider mp ON m.provider_id = mp.id " +
      "WHERE mp.id = ? ";

    boolean hasMember = searchMember != null && !searchMember.trim().isEmpty();
    if (hasMember) sql += " AND r.member_id = ? ";

    sql += " ORDER BY r.created_at DESC";

    try (Connection connList = DriverManager.getConnection(connURL);
         PreparedStatement ps = connList.prepareStatement(sql)) {

        ps.setInt(1, Integer.parseInt(selectedProviderId));
        if (hasMember)
            ps.setInt(2, Integer.parseInt(searchMember.trim()));

        try (ResultSet rs = ps.executeQuery()) {
%>

<!-- Reviews Table -->
<div class="bg-white shadow rounded-xl p-6">
    <table class="w-full border rounded-xl overflow-hidden">
        <thead class="bg-indigo-100">
            <tr>
                <th class="p-3 text-left">ID</th>
                <th class="p-3 text-left">Member ID</th>
                <th class="p-3 text-left">Meal Info</th>
                <th class="p-3 text-left">Rating</th>
                <th class="p-3 text-left">Review</th>
                <th class="p-3 text-left">Created</th>
                <th class="p-3 text-left">Action</th>
            </tr>
        </thead>

        <tbody class="divide-y">

<%
boolean found = false;
while (rs.next()) {
    found = true;
%>

<tr class="hover:bg-gray-50">
    <td class="p-3"><%= rs.getInt("review_id") %></td>
    <td class="p-3"><%= rs.getInt("member_id") %></td>

    <td class="p-3">
        <div class="font-semibold"><%= rs.getString("meal_name") %></div>
        <div class="text-gray-600">S$<%= rs.getBigDecimal("price") %></div>
        <div class="text-sm text-gray-500">Provider: <%= rs.getString("provider_name") %></div>
    </td>

    <td class="p-3 font-bold text-yellow-600"><%= rs.getInt("rating") %> ★</td>

    <td class="p-3"><%= rs.getString("review_text") %></td>

    <td class="p-3 text-gray-600"><%= rs.getTimestamp("created_at") %></td>

    <td class="p-3">
        <a href="mealProviderReviews.jsp?action=delete&id=<%=rs.getInt("review_id")%>&provider_id=<%=selectedProviderId%><%= hasMember ? "&member_id="+searchMember : "" %>"
           onclick="return confirm('Delete this review?');"
           class="px-3 py-1 bg-red-600 text-white rounded-lg hover:bg-red-800">
           Delete
        </a>
    </td>
</tr>

<%
}
if (!found) {
%>
<tr>
    <td colspan="7" class="p-4 text-center text-gray-500">No reviews found.</td>
</tr>
<%
}
%>

        </tbody>
    </table>
</div>

<%
        }
    } catch (Exception e) {
        out.println("<p class='text-red-600 mt-4'>Review list error: " + e.getMessage() + "</p>");
    }

} else {
%>

<p class="text-gray-500 mt-6">Select a provider to view reviews.</p>

<%
}
%>

</body>
</html>
