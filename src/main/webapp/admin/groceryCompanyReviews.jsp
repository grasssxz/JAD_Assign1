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
String selectedCompanyId = request.getParameter("company_id");
String searchMember = request.getParameter("member_id");
String deleteId = request.getParameter("id");

/* ===================================
   DELETE REVIEW
===================================*/
if ("delete".equals(action) && deleteId != null) {
    try (Connection connDel = DriverManager.getConnection(connURL);
         PreparedStatement psDel = connDel.prepareStatement(
             "DELETE FROM grocery_review WHERE id=?"
         )) {

        psDel.setInt(1, Integer.parseInt(deleteId));
        psDel.executeUpdate();
    }

    String redirect = "groceryCompanyReviews.jsp";
    redirect += "?company_id=" + selectedCompanyId;

    if (searchMember != null && !searchMember.trim().isEmpty())
        redirect += "&member_id=" + searchMember.trim();

    response.sendRedirect(redirect);
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Grocery Company Reviews</title>
</head>

<body class="bg-gray-100 p-6">

<!-- Back button -->
<a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp"
   class="inline-block mb-6 px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-900">
  ← Back to Admin Home
</a>

<h2 class="text-3xl font-bold text-indigo-700 mb-6">Grocery Company Reviews</h2>

<!-- Filter Card -->
<div class="bg-white shadow-md rounded-xl p-6 mb-6">

<form method="get" action="groceryCompanyReviews.jsp" 
      class="grid grid-cols-1 md:grid-cols-3 gap-6">

    <!-- Company Dropdown -->
    <div>
        <label class="block text-gray-700 font-semibold mb-1">Select Company</label>
        <select name="company_id" required
            class="w-full border rounded-lg p-2 focus:ring-indigo-500 focus:border-indigo-600">

            <option value="">-- Choose Grocery Company --</option>

            <%
            try (Connection connProv = DriverManager.getConnection(connURL);
                 PreparedStatement psProv = connProv.prepareStatement(
                     "SELECT id, name FROM grocery_company WHERE is_active=1 ORDER BY name"
                 );
                 ResultSet rp = psProv.executeQuery()) {

                while (rp.next()) {
                    String cid = rp.getString("id");
                    String cname = rp.getString("name");
                    String sel = (cid.equals(selectedCompanyId) ? "selected" : "");
            %>
                <option value="<%=cid%>" <%=sel%>><%=cid%> - <%=cname%></option>
            <%
                }
            } catch (Exception e) {
                out.println("<p class='text-red-600'>Company load error: " + e.getMessage() + "</p>");
            }
            %>

        </select>
    </div>

    <!-- Member Search -->
    <div>
        <label class="block text-gray-700 font-semibold mb-1">Search Member ID</label>
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

<p class="text-sm text-gray-500 mt-3">* Select company first. Member ID filter is optional.</p>

</div>

<%
/* ===================================
   SHOW REVIEWS
===================================*/
if (selectedCompanyId != null && !selectedCompanyId.trim().isEmpty()) {

    String sql =
      "SELECT r.id AS review_id, r.member_id, r.rating, r.review_text, r.created_at, " +
      "       gc.name AS company_name " +
      "FROM grocery_review r " +
      "JOIN grocery_company gc ON r.company_id = gc.id " +
      "WHERE gc.id = ? ";

    boolean hasMember = searchMember != null && !searchMember.trim().isEmpty();
    if (hasMember) sql += " AND r.member_id = ? ";

    sql += " ORDER BY r.created_at DESC";

    try (Connection connList = DriverManager.getConnection(connURL);
         PreparedStatement ps = connList.prepareStatement(sql)) {

        ps.setInt(1, Integer.parseInt(selectedCompanyId));

        if (hasMember)
            ps.setInt(2, Integer.parseInt(searchMember.trim()));

        try (ResultSet rs = ps.executeQuery()) {
%>

<!-- Reviews Table -->
<div class="bg-white shadow-md rounded-xl p-6">

<table class="w-full border rounded-lg overflow-hidden">
    <thead class="bg-indigo-100">
        <tr>
            <th class="p-3 text-left">ID</th>
            <th class="p-3 text-left">Member ID</th>
            <th class="p-3 text-left">Company</th>
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

    <td class="p-3 font-semibold"><%= rs.getString("company_name") %></td>

    <td class="p-3 text-yellow-600 font-bold"><%= rs.getBigDecimal("rating") %> ★</td>

    <td class="p-3"><%= rs.getString("review_text") %></td>

    <td class="p-3 text-gray-600"><%= rs.getTimestamp("created_at") %></td>

    <td class="p-3">
        <a href="groceryCompanyReviews.jsp?action=delete&id=<%=rs.getInt("review_id")%>&company_id=<%=selectedCompanyId%><%= hasMember ? "&member_id="+searchMember.trim() : "" %>"
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
    <td colspan="7" class="p-4 text-center text-gray-500">
        No reviews found for this company.
    </td>
</tr>
<% } %>

    </tbody>
</table>

</div>

<%
        } // rs
    } catch (Exception e) {
        out.println("<p class='text-red-600 mt-4'>List error: " + e.getMessage() + "</p>");
    }

} else {
%>

<p class="text-gray-500 mt-6">Please select a grocery company to view reviews.</p>

<%
}
%>

</body>
</html>
