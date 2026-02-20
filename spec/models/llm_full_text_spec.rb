require "rails_helper"

RSpec.describe LLMFullText do
  let(:nav_data) do
    [
      {
        name: "Pipelines",
        children: [
          {
            name: "Getting Started",
            path: "pipelines/getting-started"
          },
          {
            name: "Configuration",
            children: [
              {
                name: "Step types",
                path: "pipelines/configuration/step-types"
              },
              {
                name: "Environment variables",
                path: "pipelines/configuration/environment-variables"
              }
            ]
          }
        ]
      },
      {
        name: "APIs",
        children: [
          {
            name: "REST API",
            path: "apis/rest-api"
          },
          {
            name: "GraphQL Schema",
            path: "apis/graphql/schemas/query"
          }
        ]
      }
    ].map(&:deep_stringify_keys)
  end

  let(:nav) { double("Nav", data: nav_data) }
  subject(:llm_full_text) { described_class.new(nav) }

  describe ".generate" do
    it "creates a new instance with Rails default_nav and calls generate" do
      default_nav = double("DefaultNav")
      allow(Rails.application.config).to receive(:default_nav).and_return(default_nav)

      instance = double("LLMFullText")
      allow(LLMFullText).to receive(:new).with(default_nav).and_return(instance)
      allow(instance).to receive(:generate).and_return("generated content")

      expect(LLMFullText.generate).to eq("generated content")
    end
  end

  describe "#generate" do
    before do
      allow(File).to receive(:exist?).and_call_original
    end

    context "when page files exist" do
      let(:nav_data) do
        [
          {
            name: "Test Section",
            children: [
              {
                name: "Test Page",
                path: "test/my-page"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "test/my_page.md")
        allow(File).to receive(:exist?).with(filepath).and_return(true)

        parsed = double("Parsed", content: "# Test Page\n\nThis is test content.")
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
      end

      it "includes the header" do
        result = llm_full_text.generate
        expect(result).to include("# Buildkite Documentation")
        expect(result).to include("> Buildkite is a platform for running fast, secure")
      end

      it "includes the section heading" do
        result = llm_full_text.generate
        expect(result).to include("## Test Section")
      end

      it "includes the page name as a heading" do
        result = llm_full_text.generate
        expect(result).to include("### Test Page")
      end

      it "includes the page URL" do
        result = llm_full_text.generate
        expect(result).to include("URL: https://buildkite.com/docs/test/my-page")
      end

      it "includes the page content" do
        result = llm_full_text.generate
        expect(result).to include("This is test content.")
      end

      it "separates pages with horizontal rules" do
        result = llm_full_text.generate
        expect(result).to include("---")
      end
    end

    context "when page files do not exist" do
      let(:nav_data) do
        [
          {
            name: "Missing Section",
            children: [
              {
                name: "Missing Page",
                path: "missing/page"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "missing/page.md")
        allow(File).to receive(:exist?).with(filepath).and_return(false)
      end

      it "skips pages that do not exist on disk" do
        result = llm_full_text.generate
        expect(result).not_to include("Missing Page")
      end
    end

    context "with ERB tags in content" do
      let(:nav_data) do
        [
          {
            name: "ERB Section",
            children: [
              {
                name: "ERB Page",
                path: "erb/page"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "erb/page.md")
        allow(File).to receive(:exist?).with(filepath).and_return(true)

        content = "Some text\n<%= image 'test.png' %>\nMore text"
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
      end

      it "strips ERB tags from content" do
        result = llm_full_text.generate
        expect(result).to include("Some text")
        expect(result).to include("More text")
        expect(result).not_to include("<%=")
        expect(result).not_to include("%>")
      end
    end

    context "with HTML comments in content" do
      let(:nav_data) do
        [
          {
            name: "Comment Section",
            children: [
              {
                name: "Comment Page",
                path: "comment/page"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "comment/page.md")
        allow(File).to receive(:exist?).with(filepath).and_return(true)

        content = "Visible text\n<!-- hidden comment -->\nMore visible text"
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
      end

      it "strips HTML comments from content" do
        result = llm_full_text.generate
        expect(result).to include("Visible text")
        expect(result).to include("More visible text")
        expect(result).not_to include("hidden comment")
      end
    end

    context "with GraphQL schema pages" do
      it "filters out GraphQL schema documentation" do
        result = llm_full_text.generate
        expect(result).not_to include("GraphQL Schema")
        expect(result).not_to include("apis/graphql/schemas/query")
      end
    end

    context "with dividers in navigation" do
      let(:nav_data) do
        [
          {
            name: "Test Section",
            children: [
              {
                name: "Valid Page",
                path: "test/valid"
              },
              {
                type: "divider"
              },
              {
                name: "Another Page",
                path: "test/another"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        valid_filepath = Rails.root.join("pages", "test/valid.md")
        another_filepath = Rails.root.join("pages", "test/another.md")

        allow(File).to receive(:exist?).with(valid_filepath).and_return(true)
        allow(File).to receive(:exist?).with(another_filepath).and_return(true)

        parsed_valid = double("Parsed", content: "Valid content")
        parsed_another = double("Parsed", content: "Another content")

        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(valid_filepath).and_return(parsed_valid)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(another_filepath).and_return(parsed_another)
      end

      it "skips dividers and includes valid pages" do
        result = llm_full_text.generate
        expect(result).to include("Valid content")
        expect(result).to include("Another content")
        expect(result).not_to include("divider")
      end
    end

    context "with nested navigation" do
      before do
        # Set up files for the nested nav_data fixture
        getting_started = Rails.root.join("pages", "pipelines/getting_started.md")
        step_types = Rails.root.join("pages", "pipelines/configuration/step_types.md")
        env_vars = Rails.root.join("pages", "pipelines/configuration/environment_variables.md")
        rest_api = Rails.root.join("pages", "apis/rest_api.md")

        allow(File).to receive(:exist?).with(getting_started).and_return(true)
        allow(File).to receive(:exist?).with(step_types).and_return(true)
        allow(File).to receive(:exist?).with(env_vars).and_return(true)
        allow(File).to receive(:exist?).with(rest_api).and_return(true)

        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(getting_started)
          .and_return(double("Parsed", content: "Getting started content"))
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(step_types)
          .and_return(double("Parsed", content: "Step types content"))
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(env_vars)
          .and_return(double("Parsed", content: "Environment variables content"))
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(rest_api)
          .and_return(double("Parsed", content: "REST API content"))
      end

      it "flattens nested children into page entries" do
        result = llm_full_text.generate
        expect(result).to include("### Getting Started")
        expect(result).to include("### Step types")
        expect(result).to include("### Environment variables")
        expect(result).to include("### REST API")
      end

      it "includes content from all nested pages" do
        result = llm_full_text.generate
        expect(result).to include("Getting started content")
        expect(result).to include("Step types content")
        expect(result).to include("Environment variables content")
        expect(result).to include("REST API content")
      end
    end
  end
end
