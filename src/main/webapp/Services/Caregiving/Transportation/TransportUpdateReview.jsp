<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<script src="https://cdn.tailwindcss.com"></script>

<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    int providerId = Integer.parseInt(request.getParameter("provider_id"));
    int editReviewId = Integer.parseInt(request.getParameter("review_id"));
    Integer memberId = (Integer) session.getAttribute("member_id");


    PreparedStatement ps = conn.prepareStatement(
        "SELECT p.*, IFNULL(AVG(r.rating), 0) AS rating " +
        "FROM transport_provider p " +
        "LEFT JOIN transport_review r ON p.id = r.provider_id " +
        "WHERE p.id = ?"
    );
    ps.setInt(1, providerId);
    ResultSet provider = ps.executeQuery();
    provider.next();
%>

<div class="max-w-6xl mx-auto mt-12 p-4">

    <!-- PROVIDER NAME -->
    <h1 class="text-4xl font-bold mb-6"><%= provider.getString("name") %></h1>

    <!-- PROVIDER DETAILS -->
    <div class="bg-white shadow rounded-xl p-6 mb-12">

        <img src="<%= request.getContextPath() %>/home/Images/TransportMap.png"
             class="w-full h-80 object-cover rounded-lg mb-6" />

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">

            <!-- INFO -->
            <div class="space-y-2 text-gray-800">
                <p class="text-yellow-600 font-semibold text-lg">
                    ⭐ <%= provider.getDouble("rating") %> / 5
                </p>
                <p><b>Base Fee:</b> $<%= provider.getDouble("base_fee") %></p>
                <p><b>Estimated Time:</b> <%= provider.getString("est_time") %></p>
                <p><b>Location:</b> <%= provider.getString("location") %></p>
                <p><b>Vehicle Type:</b> <%= provider.getString("vehicle_type") %></p>

                <% if (provider.getBoolean("wheelchair_friendly")) { %>
                    <p class="text-green-600 font-semibold">
                        ♿ Wheelchair Friendly
                    </p>
                <% } %>
            </div>

            <!-- BOOKING -->
            <div class="bg-gray-50 p-6 rounded-lg border">
                <h2 class="text-xl font-semibold mb-4">Book Transportation</h2>

                <form method="POST" action="TransportBooking.jsp" class="space-y-3">
                    <input type="hidden" name="provider_id" value="<%= providerId %>">

                    <label class="font-medium">Select Date</label>
                    <input type="date" name="booking_date" required
                           class="border px-3 py-2 rounded w-full">

                    <button class="bg-blue-600 text-white py-2 rounded w-full hover:bg-blue-700">
                        Proceed to Booking
                    </button>
                </form>
            </div>

        </div>
    </div>

    <!-- CUSTOMER REVIEWS -->
    <h2 class="text-3xl font-semibold mb-6">Customer Reviews</h2>

    <!-- SUBMIT REVIEW CARD -->
    <div class="bg-white shadow rounded-xl p-6 mb-12 max-w-3xl mx-auto">

        <% if (memberId != null) { %>

        <form action="TransportSubmitReview.jsp" method="POST" class="space-y-5">
            <input type="hidden" name="provider_id" value="<%= providerId %>">
            <input type="hidden" name="member_id" value="<%= memberId %>">

            <div>
                <label class="font-medium block mb-1">Rating</label>
                <select name="rating" required class="border px-3 py-2 rounded w-full">
                    <option value="">Select rating</option>
                    <option value="1">1 ★</option>
                    <option value="2">2 ★</option>
                    <option value="3">3 ★</option>
                    <option value="4">4 ★</option>
                    <option value="5">5 ★</option>
                </select>
            </div>

            <div>
                <label class="font-medium block mb-1">Review</label>
                <textarea name="review" rows="5" class="border px-3 py-2 rounded w-full"
                          placeholder="Share your experience..."></textarea>
            </div>

            <button class="bg-green-600 text-white py-2 rounded w-full hover:bg-green-700">
                Submit Review
            </button>
        </form>

        <% } else { %>
            <p>Please <a href="/login/login.html" class="text-blue-600 underline">login</a> to submit a review.</p>
        <% } %>

    </div>

    <!-- REVIEW LIST -->
    <div class="space-y-8 max-w-4xl mx-auto">

        <%
            PreparedStatement psAll = conn.prepareStatement(
                "SELECT r.*, m.username FROM transport_review r " +
                "JOIN member m ON r.member_id = m.id " +
                "WHERE r.provider_id=? ORDER BY r.created_at DESC"
            );
            psAll.setInt(1, providerId);
            ResultSet rv = psAll.executeQuery();

            while (rv.next()) {
                int reviewId = rv.getInt("id");
                boolean isOwner = (memberId != null && memberId == rv.getInt("member_id"));
        %>

        <div class="bg-white shadow rounded-xl p-6 border">

            <!-- HEADER -->
            <div class="flex justify-between items-center">
                <div>
                    <p class="font-semibold text-lg"><%= rv.getString("username") %></p>
                    <p class="text-sm text-gray-500"><%= rv.getString("created_at") %></p>
                </div>

                <span class="bg-yellow-400 text-white font-bold px-3 py-1 rounded-lg">
                    <%= rv.getInt("rating") %> ★
                </span>
            </div>

            <!-- REVIEW TEXT -->
            <p id="reviewText<%= reviewId %>" class="mt-4 text-gray-800">
                <%= rv.getString("review") %>
            </p>

            <!-- EDIT FORM -->
            <form id="editForm<%= reviewId %>" method="POST"
                  action="TransportUpdateReview.jsp"
                  class="hidden space-y-3 mt-4">
                <input type="hidden" name="review_id" value="<%= reviewId %>">
                <input type="hidden" name="provider_id" value="<%= providerId %>">

                <textarea name="review" rows="3"
                          class="border px-3 py-2 rounded w-full"><%= rv.getString("review") %></textarea>

                <div class="flex gap-3">
                    <button class="bg-blue-600 text-white px-4 py-1 rounded-lg h-9 hover:bg-blue-700">Save</button>
                    <button type="button"
                            onclick="cancelEdit(<%= reviewId %>)"
                            class="bg-gray-300 px-4 py-1 rounded-lg h-9 hover:bg-gray-400">Cancel</button>
                </div>
            </form>

            <!-- OWNER ACTIONS -->
            <% if (isOwner) { %>
            <div class="flex gap-4 mt-4">
                <button onclick="editReview(<%= reviewId %>)"
                        class="bg-blue-600 text-white px-4 py-1 rounded-lg h-9 hover:bg-blue-700">
                    Edit
                </button>

                <form action="TransportDeleteReview.jsp"
                      method="POST" class="inline-block"
                      onsubmit="return confirm('Delete this review?');">
                    <input type="hidden" name="review_id" value="<%= reviewId %>">
                    <button class="bg-red-600 text-white px-4 py-1 rounded-lg h-9 hover:bg-red-700">
                        Delete
                    </button>
                </form>
            </div>
            <% } %>

            <!-- REPLY SECTION -->
            <%
                PreparedStatement psReply = conn.prepareStatement(
                    "SELECT * FROM transport_reply WHERE review_id=?"
                );
                psReply.setInt(1, reviewId);
                ResultSet rep = psReply.executeQuery();
            %>

            <% if (rep.next()) { %>
            <div class="border-l-4 border-blue-400 pl-4 mt-6">

                <p class="font-semibold text-blue-600">Provider Reply</p>

                <p id="replyText<%= rep.getInt("id") %>" class="text-gray-700 mt-2">
                    <%= rep.getString("reply_text") %>
                </p>

                <!-- EDIT REPLY -->
                <form id="replyEditForm<%= rep.getInt("id") %>"
                      action="TransportUpdateReply.jsp"
                      method="POST"
                      class="hidden space-y-3 mt-3">
                    <input type="hidden" name="reply_id" value="<%= rep.getInt("id") %>">
                    <textarea name="reply_text" class="border px-3 py-2 rounded w-full"
                              rows="2"><%= rep.getString("reply_text") %></textarea>

                    <div class="flex gap-3">
                        <button class="bg-blue-600 text-white px-4 py-1 rounded-lg h-9">Save</button>
                        <button type="button"
                                onclick="cancelReply(<%= rep.getInt("id") %>)"
                                class="bg-gray-300 px-4 py-1 rounded-lg h-9">Cancel</button>
                    </div>
                </form>

                <!-- REPLY BUTTONS -->
                <div class="flex gap-4 mt-3">
                    <button onclick="editReply(<%= rep.getInt("id") %>)"
                            class="bg-blue-600 text-white px-4 py-1 rounded-lg h-9">Edit Reply</button>

                    <form method="POST" action="TransportDeleteReply.jsp" class="inline-block">
                        <input type="hidden" name="reply_id" value="<%= rep.getInt("id") %>">
                        <button class="bg-red-600 text-white px-4 py-1 rounded-lg h-9 hover:bg-red-700">
                            Delete Reply
                        </button>
                    </form>
                </div>
            </div>

            <% } else { %>

            <!-- NEW REPLY -->
            <form method="POST" action="TransportSubmitReply.jsp" class="mt-5">
                <input type="hidden" name="review_id" value="<%= reviewId %>">

                <textarea name="reply_text"
                          class="border px-3 py-2 rounded w-full"
                          rows="2"
                          placeholder="Write a reply..."></textarea>

                <button class="bg-blue-600 text-white px-4 py-1 mt-2 rounded-lg h-9 hover:bg-blue-700">
                    Reply
                </button>
            </form>

            <% } %>

        </div>

        <% } %>

    </div>

</div>

<script>
function editReview(id) {
    document.getElementById("reviewText" + id).classList.add("hidden");
    document.getElementById("editForm" + id).classList.remove("hidden");
}
function cancelEdit(id) {
    document.getElementById("reviewText" + id).classList.remove("hidden");
    document.getElementById("editForm" + id).classList.add("hidden");
}

function editReply(id) {
    document.getElementById("replyText" + id).classList.add("hidden");
    document.getElementById("replyEditForm" + id).classList.remove("hidden");
}
function cancelReply(id) {
    document.getElementById("replyText" + id).classList.remove("hidden");
    document.getElementById("replyEditForm" + id).classList.add("hidden");
}
</script>

<%
    provider.close();
    ps.close();
    conn.close();
%>
