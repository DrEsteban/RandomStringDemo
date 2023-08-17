using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace StringFetcher.Data;

public class StringEntry
{
    public StringEntry() { }

    public StringEntry(int id, string value) => (Id, Quote) = (id, value);

    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public string? Quote { get; set; }
}
