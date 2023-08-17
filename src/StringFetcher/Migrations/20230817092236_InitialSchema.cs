using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace StringFetcher.Migrations
{
    /// <inheritdoc />
    public partial class InitialSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "StringsTable",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Value = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StringsTable", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "StringsTable",
                columns: new[] { "Id", "Value" },
                values: new object[,]
                {
                    { 1, "This is random string #1" },
                    { 2, "This is random string #2" },
                    { 3, "This is random string #3" },
                    { 4, "This is random string #4" },
                    { 5, "This is random string #5" },
                    { 6, "This is random string #6" },
                    { 7, "This is random string #7" },
                    { 8, "This is random string #8" },
                    { 9, "This is random string #9" },
                    { 10, "This is random string #10" },
                    { 11, "This is random string #11" },
                    { 12, "This is random string #12" },
                    { 13, "This is random string #13" },
                    { 14, "This is random string #14" },
                    { 15, "This is random string #15" },
                    { 16, "This is random string #16" },
                    { 17, "This is random string #17" },
                    { 18, "This is random string #18" },
                    { 19, "This is random string #19" },
                    { 20, "This is random string #20" },
                    { 21, "This is random string #21" },
                    { 22, "This is random string #22" },
                    { 23, "This is random string #23" },
                    { 24, "This is random string #24" },
                    { 25, "This is random string #25" },
                    { 26, "This is random string #26" },
                    { 27, "This is random string #27" },
                    { 28, "This is random string #28" },
                    { 29, "This is random string #29" },
                    { 30, "This is random string #30" },
                    { 31, "This is random string #31" },
                    { 32, "This is random string #32" },
                    { 33, "This is random string #33" },
                    { 34, "This is random string #34" },
                    { 35, "This is random string #35" },
                    { 36, "This is random string #36" },
                    { 37, "This is random string #37" },
                    { 38, "This is random string #38" },
                    { 39, "This is random string #39" },
                    { 40, "This is random string #40" },
                    { 41, "This is random string #41" },
                    { 42, "This is random string #42" },
                    { 43, "This is random string #43" },
                    { 44, "This is random string #44" },
                    { 45, "This is random string #45" },
                    { 46, "This is random string #46" },
                    { 47, "This is random string #47" },
                    { 48, "This is random string #48" },
                    { 49, "This is random string #49" },
                    { 50, "This is random string #50" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "StringsTable");
        }
    }
}
