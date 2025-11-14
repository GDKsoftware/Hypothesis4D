# Hypothesis for Delphi - Project Context

## Project Guidelines

This project uses three key guideline documents located in the `.docs` folder:

1. **Interaction Guidelines** (`.docs/gdk-ai-interaction-guidelines.md`)
   - How to communicate with the developer
   - Question patterns and clarification approach
   - Code delivery workflow
   - Context awareness for UI work

2. **Delphi Coding Style Guide** (`.docs/gdk-delphi-coding-guidelines.md`)
   - Naming conventions and code structure
   - Language-specific rules and patterns
   - Architecture principles
   - Quality standards

3. **Hypothesis4D Coding Guidelines** (`.docs/hypothesis-coding-guidelines.md`)
   - Project-specific naming conventions
   - Architecture and component organization
   - Generator implementation patterns
   - Test structure and patterns
   - Attribute usage and formatting

**Important**: Always follow all three documents when assisting with this codebase. Read them before starting any development work.

## Adding New Files to the Project

**IMPORTANT**: When creating new Pascal units (`.pas` files), you MUST:

1. **Ask the developer to add the file to the Delphi project (after creating the file)**
2. **Provide clear instructions** about:
   - The file path where the new unit should be created
   - The purpose of the new unit

**Rationale**: Delphi projects require `.pas` files to be registered in the `.dpr` or `.dproj` project files. Simply creating a file in the file system will result in compilation errors ("Unit not found"). The developer must add the unit to the project using the Delphi IDE or by manually editing the project files.

## Documentation Language

**All documentation, plans, todo lists, and written content MUST be in English**, regardless of the language used in prompts or conversations. This includes:

- All `.md` files (README.md, CLAUDE.md, todo.md, InitialPlan.md, etc.)
- Code comments and documentation
- Commit messages
- Issue descriptions
- Any other written project documentation

This ensures the project remains accessible to international developers and maintains consistency across all documentation.

## Project Goal

This project develops a minimal property-based testing library for Delphi, inspired by Python's Hypothesis library.

## Initial Plan

The complete initial plan and requirements are documented in:

**[.docs/InitialPlan.md](.docs/InitialPlan.md)**

## Project Status

- **Phase**: ✅ MVP Complete
- **Implementation**: All core features are implemented and tested
- **Status**: See [.docs/todo.md](.docs/todo.md) for complete project status and future improvements

**Important**: When completing tasks, [.docs/todo.md](.docs/todo.md) must be updated to reflect the current project status.

## Git Commit Guidelines

When making commits:

- **No references to AI tools**: Do NOT add references to Claude Code, Anthropic, or other AI tools in commit messages
- **Concise summary**: A short, clear summary of the change is sufficient
- **No extensive lists**: It doesn't need to be a detailed list of all changes
- **Focus on the "why"**: Explain why the change was made, not all the details of what changed

**Example of good commit message**:
```
Fix: Correct parameter attribute formatting in test methods

Updated test methods to follow the parameter attributes formatting
guidelines for better consistency.
```

**Example of bad commit message**:
```
Fix parameter formatting

Changes:
- Updated line 23 in file X
- Changed spacing in file Y
- Modified alignment in file Z

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Building the Project

### Build Unit Tests

To build the unit tests:

1. Navigate to the test directory:
   ```
   cd Delphi.Source\tests
   ```

2. Run the build script:
   ```powershell
   ..\..\\.delphi-build\build-script.ps1
   ```

The build script:
- Compiles the `Hypothesis4D.UnitTests.dpr` project
- Uses the configuration from `.delphi-build\delphi.config.json`

**Note**: The build configuration must first be created locally by running the setup script from the `.delphi-build` directory.

### Run Unit Tests

After building, you can run the unit tests:

```powershell
.\Delphi.Source\tests\Win32\Debug\Hypothesis4D.UnitTests.exe --consolemode:Quiet
```

**IMPORTANT**: After every major change to the code you MUST automatically:
1. Build the unit tests (see above)
2. Run the unit tests with `--consolemode:Quiet`
3. Verify that all tests pass (0 failed, 0 errored)

This ensures that regressions are caught immediately and code quality is maintained.

## Quick Reference

### Target
- Delphi 11 or newer
- DUnitX test framework
- Custom attributes for strategy declaration

### Scope (MVP)
- **Data Types**: Integers + Strings
- **Integer Strategies**: IntRange, IntPositive, IntNegative, IntNonZero
- **String Strategies**: StringGen, StringAlpha, StringNumeric
- **Features**: Basic shrinking, 10 default iterations (configurable)
- **No Database**: Focus on core functionality

### Example Usage

```pascal
type
  [TestFixture]
  TMyPropertyTests = class
  public
    [Test]
    procedure RunTestStringReverse;

    [ForAll(100)]
    procedure TestStringReverse([StringAlpha('Text', 0, 50)] const Text: string);
  end;

implementation

procedure TMyPropertyTests.RunTestStringReverse;
begin
  THypothesis.Run(Self, 'TestStringReverse');
end;
```

## Source Material

The original Python Hypothesis library is in the `Python.Source/` folder and was used for analysis and inspiration.