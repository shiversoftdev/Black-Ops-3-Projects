namespace Microsoft.VisualStudio.Project.Samples.CustomProject.UnitTests
{
    using Microsoft.VsSDK.UnitTestLibrary;
    using ObjectExtenders = EnvDTE.ObjectExtenders;

    public static class MockObjectExtenders
    {
        private static GenericMockFactory factory;

        static MockObjectExtenders()
        {
            factory = new GenericMockFactory("MockObjectExtenders", new[] { typeof(ObjectExtenders) });
        }

        public static BaseMock GetInstance()
        {
            return factory.GetInstance();
        }
    }
}
