import dynamic from "next/dynamic";

const SupersetEmbed = dynamic(
  () => import("../components/SupersetEmbed"),
  { ssr: false }
);

export default function Home() {
  return (
    <div>
      <h1>Dashboard</h1>
      <SupersetEmbed />
    </div>
  );
}