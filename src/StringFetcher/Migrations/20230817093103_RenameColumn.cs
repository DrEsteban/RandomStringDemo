using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StringFetcher.Migrations
{
    /// <inheritdoc />
    public partial class RenameColumn : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Value",
                table: "StringsTable",
                newName: "Quote");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Quote",
                table: "StringsTable",
                newName: "Value");
        }
    }
}
